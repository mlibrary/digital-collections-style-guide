module.exports = function (eleventyConfig) {
  // Copy everything in static to _site
  eleventyConfig.addPassthroughCopy("static");
};
