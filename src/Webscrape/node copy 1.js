const puppeteer = require('puppeteer');
const cheerio = require('cheerio');
const mysql = require('mysql2/promise');
const { PromisePool } = require('@supercharge/promise-pool');

const CONCURRENCY = 4;
const BATCH_SIZE = 1000;

(async () => {
  console.time("Execution time");

  const connection = await mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '1234',
    database: 'bolig',
    namedPlaceholders: true
  });

  const [allRows] = await connection.execute('SELECT id_lokalid, bestemtFastEjendomBFENr, part FROM ebr_sample10 WHERE ois = false AND part IN (1, 10, 8, 6, 4);');

  let browser = await puppeteer.launch({
    headless: false,
    devtools: true,
    args: ['--remote-debugging-port=9222', '--no-sandbox', '--disable-dev-shm-usage']
  });

  let pages = await Promise.all(Array(CONCURRENCY).fill(0).map(async () => await browser.newPage()));

  // Process in batches
  for(let i = 0; i < allRows.length; i += BATCH_SIZE){
    let rows = allRows.slice(i, i + BATCH_SIZE);
    const totalRows = rows.length;
    let processedRows = 0;

    const { results, errors } = await PromisePool
      .for(rows)
      .withConcurrency(CONCURRENCY)
      .process(async (row, index) => {
        const pageIndex = index % CONCURRENCY;
        const page = pages[pageIndex];
        const url = `https://nyt.ois.dk/search/${row.bestemtFastEjendomBFENr}`;

        await page.goto(url);
        await page.waitForTimeout(2500);

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
      });

    // Close all pages after each batch
    await Promise.all(pages.map(page => page.close()));

    // Open new pages for the next batch
    pages = await Promise.all(Array(CONCURRENCY).fill(0).map(async () => await browser.newPage()));
  }

  await browser.close();
  await connection.end();

  console.timeEnd("Execution time");
  console.log("done");
})();
