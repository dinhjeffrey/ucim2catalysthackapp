    		function buildBar(ds){


				var barTooltip = d3.select("body").append("div")   
				    .attr("class", "tooltip")               
				    .style("opacity", 0);

    			
    			var formatRatio = d3.format("%");

				var margin = {top: 20, right: 30, bottom: 30, left: 40},
				    width = 800 - margin.left - margin.right,
				    height = 200 - margin.top - margin.bottom;

				var x = d3.scale.ordinal()
				    .rangeRoundBands([0, width], .1);

				var y = d3.scale.linear()
				    .range([height, 0]);

				var xAxis = d3.svg.axis()
				    .scale(x)
				    .orient("bottom");

				var yAxis = d3.svg.axis()
				    .scale(y)
				    .orient("left")
				    .tickFormat(d3.format("s"))
				    .ticks(3);

				//get bar color

				var minProfit = d3.min(ds, function(d){ return d.profit; });
				var maxProfit = d3.max(ds, function(d){ return d.profit; });

				// console.log(minProfit);
				// console.log(maxProfit);

				var color = d3.scale.quantize()
							.domain([minProfit, maxProfit])							
							.range(['rgb(202,0,32)','rgb(244,165,130)','rgb(186,186,186)','rgb(64,64,64)']);
							

				var chart = d3.select("#barChart")
				    .attr("width", width + margin.left + margin.right)
				    .attr("height", height + margin.top + margin.bottom)
				  .append("g")
				    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

				d3.csv("2013-monthly-sales.csv", function(error, data) {
				  x.domain(data.map(function(d) { return d.month; }));
				  y.domain([0, d3.max(data, function(d) { return d.sales; })]);

				  chart.append("g")
				      .attr("class", "x-axis")
				      .attr("transform", "translate(0," + height + ")")
				      .call(xAxis);

				  chart.append("g")
				      .attr("class", "y-axis")
				      .call(yAxis);

				  chart.selectAll("#barChart")
					.data(data)
					.enter().append("rect")
					.attr("class", "bar")
					.attr("x", function(d) { return x(d.month); })
					.attr("y", function(d) { return y(d.sales); })
					.attr("height", function(d) { return height - y(d.sales); })
					.attr("width", x.rangeBand())
					.style("fill", function(d) { return color(d.profit); })
					.on("mouseover", function(d) {      

                            barTooltip.transition()        
                                .duration(500)      
                                .style("opacity", .9);      

                            var tip = "<strong>Sales:</strong> $" + formatSales(d.sales) + "<br/>";
                            var tip = tip+"<strong>Profit:</strong> $" + formatSales(d.profit)+ "<br/>";
                            var tip = tip+"<strong>Ratio:</strong> " + formatRatio(d.profit/d.sales)+ "<br/>";

                            barTooltip.html(tip)  
                                .style("left", (d3.event.pageX) + "px")     
                                .style("top", (d3.event.pageY - 28) + "px");    
                        })                  
                        .on("mouseout", function(d) {       

                            barTooltip.transition()        
                                .duration(500)      
                                .style("opacity", 0);   
                        });


				});
    		}


    		function buildLegend(data){

		    			var margin = {top: 20, right: 30, bottom: 30, left: 40},
						    width = 800 - margin.left - margin.right,
						    height = 200 - margin.top - margin.bottom;


						var minProfit = d3.min(data, function(d){ return d.profit; });
						var maxProfit = d3.max(data, function(d){ return d.profit; });

						// console.log(minProfit);
						// console.log(maxProfit);

						var color = d3.scale.quantize()
									.domain([minProfit, maxProfit])							
									.range(['rgb(202,0,32)','rgb(244,165,130)','rgb(186,186,186)','rgb(64,64,64)']);

    					//sort values for color legend

                        var barLegendData=[];

                        data.forEach(function(dv){

                        	var val = parseFloat(dv.profit)

                        	if (val) {barLegendData.push(val);}

                        });

                        barLegendData.sort(function(a,b){ return a-b;});

                        // console.log(barLegendData);

                        var header = d3.select("#barChartLegend")
				    				.attr("width", 200)
				    				.attr("height", 50)				  					
				    				.attr("transform", "translate(" + 300 + "," + -180 + ")");

				    	header.append("text").text("Profit")
				    			.attr({
				    				x: 0,
				    				y: h-185,
				    				class: "profitLabel"				    			
				    			});

                        //add color legend
                        header.selectAll(".barChartLegend")                        	
                        	.data(barLegendData)
                        	.enter()
                        	.append("rect")
                        	.attr({
								x: function(d, i) {return i * (200/barLegendData.length);},
							    y: height+margin.top,
							    width: function(d,i){ return (200/barLegendData.length); },
							    height: 10,
							  	fill: function(d) { return color(d);},		                           
							  	class: "barChartLegend"
                       		});


                        	// console.log([barLegendData[0],barLegendData[barLegendData.length-1]]);

                       	header.selectAll("text.profitLegend")
                       		.data([barLegendData[0],barLegendData[barLegendData.length-1]])
                       		.enter()
                       		.append("text")
                       		.text(function(d){ return formatSales(d);})
                       		.attr({
                       			x: function(d,i){ return (200-(margin.left/2))*i;},
                       			y: h-155,		         
                       			"font-size":"12px",
                       			"font-family":"sans-serif",
                       			class: "profitLegend"

                       		});
    		}

    		d3.csv("2013-monthly-sales.csv", function(error, data) {
	           
	           //problems?
	           if(error) {
	               	console.log(error);
	           }  else {

	           		//build something
	           		buildLegend(data);
	           		buildBar(data);                    
	           }
	            
	            
	        });  