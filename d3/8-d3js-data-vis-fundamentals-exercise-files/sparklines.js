function buildLine(ds) {


	        	var margin = {top: 20, right: 30, bottom: 30, left: 40},
				    w = 400 - margin.left - margin.right,
				    h = 100 - margin.top - margin.bottom;

	            
	            //scales
	            var xScale = d3.scale.linear()
	                        .domain([
	                                    d3.min(ds.monthlySales, function(d){ return d.month;}) ,
	                                    d3.max(ds.monthlySales, function(d){ return d.month;})
	                                ])                
	                        .range([0, w])
	                        .nice();        
	         

	            var yScale = d3.scale.linear()
	                        .domain([0, d3.max(ds.monthlySales, function(d){ return d.sales;})])
	                        .range([h,0])
	                        .nice();
	         
	            var lineFun = d3.svg.line()
	                .x(function (d) {return xScale(d.month); } )
	                .y(function (d) {return yScale(d.sales); })
	                .interpolate("linear");
	                
	                
	            var svg = d3.select("#bottomLeft").append("svg").attr({ width:w, height:h});
	            
	            var viz = svg.append("path")
	                        .attr({
	                            d: lineFun(ds.monthlySales),
	                            "stroke" : "#666666",
	                            "stroke-width": 2,
	                            "fill" : "none"
	                        });

	            
	        }
	          
	        //show header
	        function showHeader(ds) {
	            d3.select("#bottomLeft").append("h2")
	                .text(ds.category + " Sales Trend (2013)");
	        }
	        
	        
	        //get data and draw things  
	        d3.json("2013-category-sales.json", function(error, data) {
	           
	           if(error) {
	               console.log(error);               
	           } 
	            
	            data.contents.forEach(function(ds){                               
	                showHeader(ds);
	                buildLine(ds);                    
	            })
	            
	        });  