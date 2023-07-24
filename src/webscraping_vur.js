const puppeteer = require('puppeteer');
const cheerio = require('cheerio');

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();

  await page.goto('https://nyt.ois.dk/search/172357');

  // Waiting for 10 seconds for the data to load
  await page.waitForTimeout(1000);

  const data = await page.evaluate(() => {
    const ulElement = document.querySelector('ul.grid');
    return ulElement.innerHTML;
  });

  // Parse the HTML and extract the information
  const $ = cheerio.load(data);
  $('li').each(function(i, elem) {
    const text = $(this).text();
    const field = text.split(':')[0];

    // List of fields you are interested in
    const interestedFields = ["Adresse", "BFE", "Matrikel-ejerlav", "Grund-areal", "Bebygget areal", "Byggesager", "Administrator", "Ejer", "Vurdering", "Salgspris"];

    if (interestedFields.includes(field)) {
      console.log(text);
    }
  });

  await browser.close();
})();
