import Toybox.Activity;
import Toybox.Lang;
import Toybox.Sensor;
import Toybox.Time;
import Toybox.WatchUi;

class BestTempView extends WatchUi.SimpleDataField {
    var lastTempValue = 0;


    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
 //       Sensor.setEnabledSensors([Sensor.SENSOR_TEMPERATURE]);
 //       Sensor.enableSensorEvents( method(:onTempSensor) );
        label = "Meteo °C";
    }

 //   function onTempSensor(sensorInfo as Sensor.Info) as Void {
 //       lastTempValue = sensorInfo.temperature;
 //       System.println("Temperature: " + sensorInfo.temperature);
 //   }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        // See Activity.Info in the documentation for available information.
        
        return Weather.getCurrentConditions().temperature;
    }

}