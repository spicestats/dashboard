$(function(){
	$('#selectorid').highcharts(
{
  "chart": {
    "reflow": true
  },
  "title": {
    "text": "Median house prices in Central Scotland, 2022"
  },
  "yAxis": {
    "title": "",
    "type": "linear",
    "labels": {
      "format": "£{value: ,f}"
    }
  },
  "credits": {
    "enabled": false
  },
  "exporting": {
    "enabled": false
  },
  "boost": {
    "enabled": false
  },
  "plotOptions": {
    "series": {
      "label": {
        "enabled": false
      },
      "turboThreshold": 0,
      "showInLegend": false
    },
    "treemap": {
      "layoutAlgorithm": "squarified"
    },
    "scatter": {
      "marker": {
        "symbol": "circle"
      }
    }
  },
  "series": [
    {
      "group": "group",
      "data": [
        {
          "Area_name": "Scotland",
          "Area_type": "Country",
          "Region": null,
          "Subject": "Housing",
          "Measure": "Median house price",
          "TimePeriod": 2022,
          "Year": 2022,
          "Month": null,
          "Sex": "All",
          "Age": "All",
          "CTBand": "All",
          "Data": 180000,
          "Lower": null,
          "Upper": null,
          "y": 180000,
          "name": "Scotland"
        },
        {
          "Area_name": "Coatbridge and Chryston",
          "Area_type": "SP Constituency",
          "Region": "Central Scotland",
          "Subject": "Housing",
          "Measure": "Median house price",
          "TimePeriod": 2022,
          "Year": 2022,
          "Month": null,
          "Sex": "All",
          "Age": "All",
          "CTBand": "All",
          "Data": 160000,
          "Lower": null,
          "Upper": null,
          "y": 160000,
          "name": "Coatbridge and Chryston"
        },
        {
          "Area_name": "Falkirk East",
          "Area_type": "SP Constituency",
          "Region": "Central Scotland",
          "Subject": "Housing",
          "Measure": "Median house price",
          "TimePeriod": 2022,
          "Year": 2022,
          "Month": null,
          "Sex": "All",
          "Age": "All",
          "CTBand": "All",
          "Data": 150247.5,
          "Lower": null,
          "Upper": null,
          "y": 150247.5,
          "name": "Falkirk East"
        },
        {
          "Area_name": "Hamilton, Larkhall and Stonehouse",
          "Area_type": "SP Constituency",
          "Region": "Central Scotland",
          "Subject": "Housing",
          "Measure": "Median house price",
          "TimePeriod": 2022,
          "Year": 2022,
          "Month": null,
          "Sex": "All",
          "Age": "All",
          "CTBand": "All",
          "Data": 149995,
          "Lower": null,
          "Upper": null,
          "y": 149995,
          "name": "Hamilton, Larkhall and Stonehouse"
        },
        {
          "Area_name": "Falkirk West",
          "Area_type": "SP Constituency",
          "Region": "Central Scotland",
          "Subject": "Housing",
          "Measure": "Median house price",
          "TimePeriod": 2022,
          "Year": 2022,
          "Month": null,
          "Sex": "All",
          "Age": "All",
          "CTBand": "All",
          "Data": 146000,
          "Lower": null,
          "Upper": null,
          "y": 146000,
          "name": "Falkirk West"
        },
        {
          "Area_name": "East Kilbride",
          "Area_type": "SP Constituency",
          "Region": "Central Scotland",
          "Subject": "Housing",
          "Measure": "Median house price",
          "TimePeriod": 2022,
          "Year": 2022,
          "Month": null,
          "Sex": "All",
          "Age": "All",
          "CTBand": "All",
          "Data": 137000,
          "Lower": null,
          "Upper": null,
          "y": 137000,
          "name": "East Kilbride"
        },
        {
          "Area_name": "Uddingston and Bellshill",
          "Area_type": "SP Constituency",
          "Region": "Central Scotland",
          "Subject": "Housing",
          "Measure": "Median house price",
          "TimePeriod": 2022,
          "Year": 2022,
          "Month": null,
          "Sex": "All",
          "Age": "All",
          "CTBand": "All",
          "Data": 130000,
          "Lower": null,
          "Upper": null,
          "y": 130000,
          "name": "Uddingston and Bellshill"
        },
        {
          "Area_name": "Airdrie and Shotts",
          "Area_type": "SP Constituency",
          "Region": "Central Scotland",
          "Subject": "Housing",
          "Measure": "Median house price",
          "TimePeriod": 2022,
          "Year": 2022,
          "Month": null,
          "Sex": "All",
          "Age": "All",
          "CTBand": "All",
          "Data": 125000,
          "Lower": null,
          "Upper": null,
          "y": 125000,
          "name": "Airdrie and Shotts"
        },
        {
          "Area_name": "Cumbernauld and Kilsyth",
          "Area_type": "SP Constituency",
          "Region": "Central Scotland",
          "Subject": "Housing",
          "Measure": "Median house price",
          "TimePeriod": 2022,
          "Year": 2022,
          "Month": null,
          "Sex": "All",
          "Age": "All",
          "CTBand": "All",
          "Data": 120000,
          "Lower": null,
          "Upper": null,
          "y": 120000,
          "name": "Cumbernauld and Kilsyth"
        },
        {
          "Area_name": "Motherwell and Wishaw",
          "Area_type": "SP Constituency",
          "Region": "Central Scotland",
          "Subject": "Housing",
          "Measure": "Median house price",
          "TimePeriod": 2022,
          "Year": 2022,
          "Month": null,
          "Sex": "All",
          "Age": "All",
          "CTBand": "All",
          "Data": 118003.5,
          "Lower": null,
          "Upper": null,
          "y": 118003.5,
          "name": "Motherwell and Wishaw"
        }
      ],
      "type": "bar",
      "name": 2022
    }
  ],
  "xAxis": {
    "type": "category"
  },
  "colors": ["#003057", "#007DBA", "#00A9E0", "#108765", "#568125", "#B0008E", "#B884CB", "#E40046", "#E87722", "#CC8A00", "#DAAA00"],
  "tooltip": {
    "valueDecimals": 0,
    "valuePrefix": "£",
    "xDateFormat": "%b %Y"
  }
}
);
});
