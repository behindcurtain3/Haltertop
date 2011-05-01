$(function(){
    // Setup our canvas
    var canvas = document.getElementById("game");
    var context = canvas.getContext("2d");

    // Height & Width variables
    var height = 64;
    var width = 64;
    var darkColor = "#987";
    var lightColor = "#fff";

    // Pieces image
    var pieces = new Image();
    pieces.src = "images/chess-set-symbols.png";
    pieces.onload = function(){
      // Draw pieces in their right places
      // Black king
      context.drawImage(pieces, 0, 0, 90, 90, 0, 0, 64,64);
    }

    // Tracks whether to draw a black or white square
    var blackSquare = false;

    // Draw the board
    for(var y = 0; y < 8; y++){
      for(var x = 0; x < 8; x++){
	if(blackSquare){
	  context.fillStyle = lightColor;
	} else {
	  context.fillStyle = darkColor;
	}
	context.fillRect(x * width, y * height, width, height);
	blackSquare = !blackSquare;
      }
      blackSquare = !blackSquare;
    }

    // Draw board border
    context.moveTo(0,0);
    context.lineTo(512,0);
    context.lineTo(512,512);
    context.lineTo(0,512);
    context.lineTo(0,0);
    context.strokeStyle = "#999";
    context.stroke();

});