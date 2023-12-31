let meterStarted = false;

const updateMeter = (meterData) => {
  $("#total-price").html("$ " + meterData.TotalPrice);
  $("#passenger").html(meterData.passenger);
  $("#halte").html(meterData.nextstation);
};

const resetMeter = () => {
  $("#total-price").html("$ 0.00");
  $("#passenger").html("0.00 mi");
};

const toggleMeter = () => {
  $(".toggle-meter-btn").html("<p>Started</p>");
  $(".toggle-meter-btn p").css({ color: "rgb(51, 160, 37)" });

};

const meterToggle = () => {
  if (!meterStarted) {
    $.post(
      `https://${GetParentResourceName()}/enableMeter`,
      JSON.stringify({
        enabled: true,
      })
    );
    toggleMeter(true);
    meterStarted = true;
  } else {
    $.post(
      `https://${GetParentResourceName()}/enableMeter`,
      JSON.stringify({
        enabled: false,
      })
    );
    toggleMeter(false);
    meterStarted = false;
  }
};

const openMeter = (meterData) => {
  $(".container").fadeIn(150);
  $("#halte").html(meterData.nextstation);
  $("#total-price").html("$ " + meterData.TotalPrice);
  $("#passenger").html(meterData.passenger);
};

const closeMeter = () => {
  $(".container").fadeOut(150);
};

$(document).ready(function () {
  $(".container").hide();
  window.addEventListener("message", (event) => {
    const eventData = event.data;
    switch (eventData.action) {
      case "openMeter":
        if (eventData.toggle) {
          openMeter(eventData.meterData);
        } else {
          closeMeter();
        }
        break;
      case "toggleMeter":
        meterToggle();
        break;
      case "updateMeter":
        updateMeter(eventData.meterData);
        break;
      case "resetMeter":
        resetMeter();
        break;
      default:
        break;
    }
  });
});
