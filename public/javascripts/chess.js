var gCanvasElement;
var gCanvasCtx;
var gPieces;
var gSelectedPieceIndex = -1;
var gGameInProgress = false;

var cBoardWidth = 8;
var cBoardHeight = 8;
var cPieceWidth = 64;
var cPieceHeight = 64;
var cDarkColor = "#987";
var cLightColor = "#fff";


function Piece(type, row, column){
    this.type = type;
    this.row = row;
    this.column = column;
}


function initGame(canvasElement){
    if(!canvasElement)
        return;

    gCanvasElement = canvasElement;
    gCanvasCtx = gCanvasElement.getContext("2d");

    newGame();
}

function newGame(){
    gPieces = [new Piece("black-king", 4,0)];

    gSelectedPieceIndex = -1;
    gGameInProgress = true;

    drawBoard();
}

function drawBoard(){
    // Tracks whether to draw a black or white square
    var blackSquare = false;

    // Draw the board
    for(var y = 0; y < cBoardHeight; y++){
      for(var x = 0; x < cBoardWidth; x++){
	if(blackSquare){
	  gCanvasCtx.fillStyle = cLightColor;
	} else {
	  gCanvasCtx.fillStyle = cDarkColor;
	}
	gCanvasCtx.fillRect(x * cPieceWidth, y * cPieceHeight, cPieceWidth, cPieceHeight);
	blackSquare = !blackSquare;
      }
      blackSquare = !blackSquare;
    }

    // Draw board border
    gCanvasCtx.moveTo(0,0);
    gCanvasCtx.lineTo(512,0);
    gCanvasCtx.lineTo(512,512);
    gCanvasCtx.lineTo(0,512);
    gCanvasCtx.lineTo(0,0);
    gCanvasCtx.strokeStyle = "#999";
    gCanvasCtx.stroke();
}


$(function(){
    initGame(document.getElementById("game"));
});