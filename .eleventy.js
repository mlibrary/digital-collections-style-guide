const stencil = require("@umich-lib/components/hydrate");

module.exports = function (eleventyConfig) {

  eleventyConfig.setUseGitIgnore(false);

  eleventyConfig.addPassthroughCopy("static");

  eleventyConfig.addPassthroughCopy('samples/qui');
  eleventyConfig.addPassthroughCopy('samples/xml');
  eleventyConfig.addPassthroughCopy('samples/js');
  eleventyConfig.addPassthroughCopy('samples/styles');
  eleventyConfig.addPassthroughCopy('samples/xsl/i/image/debug.qui.xsl');

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
