const puppeteer = require('puppeteer');
const cheerio = require('cheerio');
const mysql = require('mysql2/promise');
const { PromisePool } = require('@supercharge/promise-pool');

const CONCURRENCY = 5;

(async () => {
  console.time("Execution time");

  const connection = await mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '1234',
    database: 'bolig',
    namedPlaceholders: true
  });

  const [rows] = await connection.execute('SELECT id_lokalid, bestemtFastEjendomBFENr FROM ebr_sample10 WHERE ois = false and part = 10 LIMIT 200');

  const totalRows = rows.length;
  let processedRows = 0;

  let browser = await puppeteer.launch({
    headless: false,  // Puppeteer runs in non-headless mode
    devtools: true,   // Devtools are open by default
    args: [
      '--remote-debugging-port=9222',  // Starts a remote debugging instance on port 9222
      '--no-sandbox',  // Disables the sandbox for easier debugging
      '--disable-dev-shm-usage' // Avoids running out of memory during debugging
    ],
  });

  const { results, errors } = await PromisePool
    .for(rows)
    .withConcurrency(CONCURRENCY)
    .process(async row => {
      const page = await browser.newPage();
      const url = `https://nyt.ois.dk/search/${row.bestemtFastEjendomBFENr}`;

      await page.goto(url);
      await page.waitForTimeout(1500);

      const data = await page.evaluate(() => {
        const ulElement = document.querySelector('ul.grid');
        return ulElement ? ulElement.innerHTML : '';
      });

      const $ = cheerio.load(data);

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
          scrapedData[fieldConversion[field]] = value;
        }
      });

      console.log('Scraped Data:', scrapedData);

      await connection.execute('INSERT INTO ois (id, Adresse, BFE, Matrikel_ejerlav, Grund_areal, Bebygget_areal, Byggesager, Administrator, Ejer, Vurdering, Salgspris) VALUES (:id, :Adresse, :BFE, :Matrikel_ejerlav, :Grund_areal, :Bebygget_areal, :Byggesager, :Administrator, :Ejer, :Vurdering, :Salgspris)', scrapedData);
      await connection.execute('UPDATE ebr_sample10 SET ois = true WHERE id_lokalid = ?', [row.id_lokalid]);

      processedRows++;

      console.log(`Progress: ${processedRows}/${totalRows} (${(processedRows / totalRows * 100).toFixed(2)}%)`);

      await page.close();
    });

  await browser.close();
  await connection.end();

  console.timeEnd("Execution time");
  console.log("done");
})();
