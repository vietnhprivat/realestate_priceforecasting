const cheerio = require('cheerio');

// HTML text
const html_text = `
<li><strong>Adresse: </strong>Anker Heegaards Gade 1B, 2., 1572 København V</li>
<li><strong>BFE: </strong>172356</li>
<li><strong>Kommune: </strong>København (0101)</li>
<li><strong>Matrikel-ejerlav: </strong>291 - Vestervold Kvarter, København</li>
<li><strong>Grund-areal: </strong>1.215 m²</li>
<li><strong>Bebygget areal: </strong>901 m²</li>
<li><strong>Byggesager: </strong>Ja</li>
<li><strong>Administrator: </strong></li>
<li><strong>Ejer: </strong>Kampmannsgaard P/S</li>
<li><strong>Vurdering: </strong>2.250.000 (2022)</li>
<li><strong>Salgspris: </strong></li>
`;

const $ = cheerio.load(html_text);
$('li').each(function(i, elem) {
  const text = $(this).text();
  const field = text.split(':')[0];
  
  // List of fields you are interested in
  const interestedFields = ["Adresse", "BFE", "Matrikel-ejerlav", "Grund-areal", "Bebygget areal", "Byggesager", "Administrator", "Ejer", "Vurdering", "Salgspris"];

  if (interestedFields.includes(field)) {
    console.log(text);
  }
});
