import Toybox.Activity;
import Toybox.Lang;
import Toybox.Sensor;
import Toybox.Time;
import Toybox.WatchUi;

class HappyDogAppView extends WatchUi.SimpleDataField {
    const DISTANCE_MAX = 10000;
    const TIME_MAX = 2 * 3600 * 1000;
    const ASCENT_MAX = 400;

    var doggyPoints = 0;


    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = "Happy Dog";
    }

    /**
      Calculate happy dog index. This consists of three measures:
       - distance
       - time
       - sum of ascents

      Distance of 10km will give 40 points. Time of 2h will give next 40 points. Sum of ascents of 400m will give 20 points.
      Points are summed, so a walk of 10km in 2 hours with 400m ascents gives 100 points
    */

    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        try {
            // elapsedDistance is in meters
            var distancePoints = info.elapsedDistance * 40 / DISTANCE_MAX;

            // elapsedTime is in milliseconds
            var timePoints = info.timerTime.toFloat() * 40 / TIME_MAX;

            // totalAscent is in meters
            var ascentPoints = info.totalAscent.toFloat() * 20 / ASCENT_MAX;

            doggyPoints = distancePoints + timePoints + ascentPoints;
        }
        catch (Exception)
        { 
            doggyPoints = "?";
        }
        return doggyPoints;
    }
}