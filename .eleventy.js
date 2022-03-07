const stencil = require("@umich-lib/components/hydrate");

module.exports = function (eleventyConfig) {

  eleventyConfig.setUseGitIgnore(false);

  eleventyConfig.addPassthroughCopy("static");
  eleventyConfig.addPassthroughCopy("styles");
  // eleventyConfig.addPassthroughCopy('js');
  eleventyConfig.addPassthroughCopy('dist');
  eleventyConfig.addPassthroughCopy('templates/debug.qui.xsl');

  eleventyConfig.addPassthroughCopy('samples/qui');
  eleventyConfig.addPassthroughCopy('samples/data');

  // --- setUseGitIgnore(false) we shouldn't need these
  // eleventyConfig.addPassthroughCopy('samples/qbat');
  // eleventyConfig.addPassthroughCopy('samples/index.html');

  // Server side rendering for @umich-lib/components.
  // eleventyConfig.addTransform("ssr", async (content, outputPath) => {
  //   if (outputPath.endsWith(".html")) {
  //     try {
  //       const { html } = await stencil.renderToString(content);
  //       return html;
  //     } catch (error) {
  //       return error;
  //     }
  //   }
  //   return content;
  // });
};
