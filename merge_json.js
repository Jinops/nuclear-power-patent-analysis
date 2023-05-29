const fs = require('fs');
const path = require('path');

const resultFileName = 'All.json';
let patents = [];
let fileNames = fs.readdirSync('./datas');

for (const fileName of fileNames){
  if (fileName == resultFileName)
    continue;

  if(path.extname(fileName) === '.json') {
    const file = fs.readFileSync(`./datas/${fileName}`, 'utf8');
    const obj = JSON.parse(file);
    patents.push(...obj.patents);
    console.log(fileName, obj.patents.length)
  }
}
console.log('----------------')
console.log(resultFileName, patents.length)
fs.writeFileSync(`./datas/${resultFileName}`, JSON.stringify({patents}));