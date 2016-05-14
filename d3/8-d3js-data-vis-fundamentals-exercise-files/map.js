		var margin = {top: 20, right: 30, bottom: 30, left: 40},
				    w = 400 - margin.left - margin.right,
				    h = 400 - margin.top - margin.bottom;

		            
		            var projection = d3.geo.albersUsa()
                                   .translate([w/2+10, (h/2)-80])
                                   .scale([h+50]);

		            
		            var path = d3.geo.path()
								.projection(projection);
		                             
		            var color = d3.scale.linear()				
							.range(['rgb(229,245,224)','rgb(199,233,192)','rgb(161,217,155)','rgb(116,196,118)','rgb(65,171,93)','rgb(35,139,69)','rgb(0,90,50)']);

		                                

		            //Create SVG element
		            var svg = d3.select("#bottomRight")
		                        .append("svg")
		                        .attr("width", w)
		                        .attr("height", h);


		            //Load in Sales Data
		            d3.csv("2013-state-sales.csv", function(data) {

		                //Set input domain for color scale
		                color.domain([0,d3.max(data, function(d) { return d.sales; })]);

		                //Load in GeoJSON data
		                d3.json("us.json", function(json) {

		                    //Merge the ag. data and GeoJSON
		                    //Loop through once for each ag. data value
		                    for (var i = 0; i < data.length; i++) {
		                
		                        //Grab state name
		                        var dataState = data[i].state;
		                        
		                        //Grab data value, and convert from string to float
		                        var dataValue = parseFloat(data[i].sales);
		                
		                        //Find the corresponding state inside the GeoJSON
		                        for (var j = 0; j < json.features.length; j++) {

						            var jsonState = json.features[j].properties.NAME;
		                
		                            if (dataState == jsonState) {
		                        
		                                json.features[j].properties.value = dataValue;
		                                break;
		                                
		                            }
		                        }       
		                    }

		                    //add tooltip
		                    var mapTooltip = d3.select("body").append("div")   
							    .attr("class", "tooltip")               
							    .attr("id", "mapTooltip")
							    .style("opacity", 0);


							 //add legend
							
				           

		                    //Build Map
		                    svg.selectAll("path")
		                       .data(json.features)
		                       .enter()
		                       .append("path")
		                       .attr("d", path)
		                       .style("fill", function(d) {
		                            //Get data value
		                            var value = d.properties.value;
		                            
		                            if (value) {
		                                //If value exists…
		                                return color(value);
		                            } else {
		                                //If value is undefined…
		                                return "#fff";
		                            }
		                       })
               					.on("mouseover", function(d) {      

		                            mapTooltip.transition()        
		                                .duration(500)      
		                                .style("opacity", .9);      

		                            var tip = "<strong>" + d.properties.NAME + "</strong><br/>"
		                            var tip = tip + "<strong>Sales:</strong> $" + formatSales(d.properties.value) + "<br/>";

		                            mapTooltip.html(tip)  
		                                .style("left", (d3.event.pageX) + "px")     
		                                .style("top", (d3.event.pageY - 28) + "px");    
		                        })                  
		                        .on("mouseout", function(d) {       

		                            mapTooltip.transition()        
		                                .duration(500)      
		                                .style("opacity", 0);   
		                        });


		                        //sort values for color legend

		                        var legendData=[];

		                        json.features.forEach(function(prop){

		                        	var val = parseFloat(prop.properties.value)

		                        	if (val) {legendData.push(val);}

		                        	
		                        });

		                        legendData.sort(function(a,b){ return a-b;});

		                        // add color legend
		                        svg.selectAll("rect")		                        	
		                        	.data(legendData)
		                        	.enter()
		                        	.append("rect")
		                        	.attr({
										x: function(d, i) {return i * (w/legendData.length);},
									    y: h-140,
									    width: function(d,i){ return (w/legendData.length); },
									    height: 10,
									  	fill: function(d) { return color(d);}				                           
		                       		});


		                        	// console.log([legendData[0],legendData[legendData.length-1]]);

		                       	svg.selectAll("text")
		                       		.data([legendData[0],legendData[legendData.length-1]])
		                       		.enter()
		                       		.append("text")
		                       		.text(function(d){ return formatSales(d);})
		                       		.attr({
		                       			x: function(d,i){ return (w-(margin.left/2))*i;},
		                       			y: h-150,		         
		                       			"font-size":"12px",
		                       			"font-family":"sans-serif"              			
		                       		});
		            
		                });
		            
		            });
