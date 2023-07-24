const puppeteer = require('puppeteer');
const cheerio = require('cheerio');
const mysql = require('mysql2/promise');


(async () => {
  console.time("Execution time");  // Start the timer
  // Connecting to MySQL
  const connection = await mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '1234',
    database: 'bolig',
    namedPlaceholders: true
  });

  // Selecting rows from the ebr table
  const [rows] = await connection.execute('SELECT id_lokalid, bestemtFastEjendomBFENr FROM ebr WHERE ois = false LIMIT 100');

  const browser = await puppeteer.launch();

  for (let row of rows) {
    const page = await browser.newPage();

    // Construct the URL using bestemtFastEjendomBFENr
    const url = `https://nyt.ois.dk/search/${row.bestemtFastEjendomBFENr}`;

    await page.goto(url);
    await page.waitForTimeout(2000);

    const data = await page.evaluate(() => {
      const ulElement = document.querySelector('ul.grid');
      return ulElement ? ulElement.innerHTML : '';
    });

    const $ = cheerio.load(data);

    // Initialize an object to hold the scraped data
    let scrapedData = {
      id: row.id_lokalid,
      Adresse: null,
      BFE: null,
      Matrikel_ejerlav: null,
      Grund_areal: null,
      Bebygget_areal: null,
      Byggesager: null,
      Administrator: null,
      Ejer: null,
      Vurdering: null,
      Salgspris: null
    };

    $('li').each(function(i, elem) {
      const text = $(this).text();
      const field = text.split(':')[0];
      const value = text.split(':')[1] ? text.split(':')[1].trim() : null;

      const interestedFields = ["Adresse", "BFE", "Matrikel-ejerlav", "Grund-areal", "Bebygget areal", "Byggesager", "Administrator", "Ejer", "Vurdering", "Salgspris"];

      const fieldConversion = {
        "Adresse": "Adresse",
        "BFE": "BFE",
        "Matrikel-ejerlav": "Matrikel_ejerlav",
        "Grund-areal": "Grund_areal",
        "Bebygget areal": "Bebygget_areal",
        "Byggesager": "Byggesager",
        "Administrator": "Administrator",
        "Ejer": "Ejer",
        "Vurdering": "Vurdering",
        "Salgspris": "Salgspris"
      };

      if (interestedFields.includes(field)) {
        // Add the field and its corresponding value to the scrapedData object
        scrapedData[fieldConversion[field]] = value;
      }
    });

    // Insert the scraped data into the ois table
    await connection.execute('INSERT INTO ois (id, Adresse, BFE, Matrikel_ejerlav, Grund_areal, Bebygget_areal, Byggesager, Administrator, Ejer, Vurdering, Salgspris) VALUES (:id, :Adresse, :BFE, :Matrikel_ejerlav, :Grund_areal, :Bebygget_areal, :Byggesager, :Administrator, :Ejer, :Vurdering, :Salgspris)', scrapedData);

    // Update the ois column in the ebr table
    await connection.execute('UPDATE ebr SET ois = true WHERE id_lokalid = ?', [row.id_lokalid]);

    await page.close();
  }

  await browser.close();
  await connection.end();

  // Print done when the script is finished
  console.timeEnd("Execution time");  // End the timer and print the elapsed time
  console.log("done");
})();
