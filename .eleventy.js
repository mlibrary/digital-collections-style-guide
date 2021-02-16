const stencil = require("@umich-lib/components/hydrate");

module.exports = function (eleventyConfig) {
  eleventyConfig.addPassthroughCopy("static");

  // Server side rendering for @umich-lib/components.
  eleventyConfig.addTransform("ssr", async (content, outputPath) => {
    if (outputPath.endsWith(".html")) {
      try {
        const { html } = await stencil.renderToString(content);
        return html;
      } catch (error) {
        return error;
      }
    }
    return content;
  });
};
