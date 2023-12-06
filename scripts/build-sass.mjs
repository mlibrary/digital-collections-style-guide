import * as sass from 'sass';
import fg from "fast-glob";
import path from "path";
import fs from "fs";

const possibles = fg.sync(
 './src/scss/**/[a-z]*.scss'
);

possibles.forEach((filename) => {
  const result = sass.compile(
    filename, {
       sourceMap: true, 
       sourceMapContents: true,
    });
  const outputFilename = filename.replace('./src/scss/', './dist/css/').replace('.scss', '.css');
  if (!fs.existsSync(path.dirname(outputFilename))) {
    fs.mkdirSync(path.dirname(outputFilename), {
      recursive: true,
      mode: 0o775,
    });
  }
  fs.writeFileSync(
    outputFilename,
    result.css + `\n\n/* #sourceMappingURL=${path.basename(outputFilename)}.map */\n`,
  );

  fs.writeFileSync(
    outputFilename + '.map',
    JSON.stringify(result.sourceMap),
  );    

  console.log("-- scss: compiled", filename);
})
