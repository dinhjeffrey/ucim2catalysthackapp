var scale = d3.scale
              .linear()
              .domain([130,350]) //input min/max of sales values
              .range([10,100]); //output pixels for SVG

console.log(scale(300)); //output 79.54
console.log(scale(270)); //output 67.27
console.log(scale(150)); //output 18.18
