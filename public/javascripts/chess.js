var gCanvasElement;
var gCanvasCtx;
var gPieces;
var gSelectedPieceIndex = -1;
var gSelectedPieceHasMove = false;
var gGameInProgress = false;
var gImages;
var gImagesLoaded = false;
var gImageLoadIndex = 0;


var cBoardWidth = 8;
var cBoardHeight = 8;
var cPieceWidth = 48;
var cPieceHeight = 48;
var cHorzSpacer = 8;
var cVertSpacer = 8;
var cCellWidth = 64;
var cCellHeight = 64;
var cDarkColor = "#f4a460";
var cLightColor = "#fff";
var cHighlightColor = "#6267f4";

function Cell(row, column){
    this.row = row;
    this.column = column;
}


function Piece(type, row, column){
    this.type = type;
    this.cell = new Cell(row, column);
}


function initGame(canvasElement){
    if(!canvasElement)
        return;

    gCanvasElement = canvasElement;
    gCanvasElement.addEventListener("click", canvasOnClick, false);
    gCanvasCtx = gCanvasElement.getContext("2d");

    // loadImages will call newGame() when finished
    loadImages();
}

function newGame(){
    gPieces = [
	new Piece("black-king", 0,4),
	new Piece("black-queen", 0,3),
	new Piece("black-rook", 0,0),
	new Piece("black-rook", 0,7),
	new Piece("black-bishop", 0,2),
	new Piece("black-bishop", 0,5),
	new Piece("black-knight", 0,1),
	new Piece("black-knight", 0,6),
	new Piece("black-pawn", 1,0),
	new Piece("black-pawn", 1,1),
	new Piece("black-pawn", 1,2),
	new Piece("black-pawn", 1,3),
	new Piece("black-pawn", 1,4),
	new Piece("black-pawn", 1,5),
	new Piece("black-pawn", 1,6),
	new Piece("black-pawn", 1,7),

	new Piece("white-king", 7,4),
	new Piece("white-queen", 7,3),
	new Piece("white-rook", 7,0),
	new Piece("white-rook", 7,7),
	new Piece("white-bishop", 7,2),
	new Piece("white-bishop", 7,5),
	new Piece("white-knight", 7,1),
	new Piece("white-knight", 7,6),
	new Piece("white-pawn", 6,0),
	new Piece("white-pawn", 6,1),
	new Piece("white-pawn", 6,2),
	new Piece("white-pawn", 6,3),
	new Piece("white-pawn", 6,4),
	new Piece("white-pawn", 6,5),
	new Piece("white-pawn", 6,6),
	new Piece("white-pawn", 6,7),
    ];

    gSelectedPieceIndex = -1;
    gGameInProgress = true;

    drawBoard();
}

function drawBoard(){
    // Tracks whether to draw a black or white square
    var blackSquare = true;

    // Draw the board
    for(var y = 0; y < cBoardHeight; y++){
      for(var x = 0; x < cBoardWidth; x++){
	if(gSelectedPieceIndex != -1){
	    if(gPieces[gSelectedPieceIndex].cell.row == y && gPieces[gSelectedPieceIndex].cell.column == x){
		gCanvasCtx.fillStyle = cHighlightColor;
	    } else {
		gCanvasCtx.fillStyle = (blackSquare) ? cLightColor : cDarkColor;
	    }
	} else {
	    gCanvasCtx.fillStyle = (blackSquare) ? cLightColor : cDarkColor;
	}
	gCanvasCtx.fillRect(x * cCellWidth, y * cCellHeight, cCellWidth, cCellHeight);
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

    // Draw pieces
    for(var i = 0; i < gPieces.length; i++){
	switch(gPieces[i].type){
	    case "black-king":
		drawImg(0, gPieces[i].cell.column, gPieces[i].cell.row);
		break;
	    case "black-queen":
		drawImg(1, gPieces[i].cell.column, gPieces[i].cell.row);
		break;
	    case "black-rook":
		drawImg(2, gPieces[i].cell.column, gPieces[i].cell.row);
		break;
	    case "black-bishop":
		drawImg(3, gPieces[i].cell.column, gPieces[i].cell.row);
		break;
	    case "black-knight":
		drawImg(4, gPieces[i].cell.column, gPieces[i].cell.row);
		break;
	    case "black-pawn":
		drawImg(5, gPieces[i].cell.column, gPieces[i].cell.row);
		break;
	    case "white-king":
		drawImg(6, gPieces[i].cell.column, gPieces[i].cell.row);
		break;
	    case "white-queen":
		drawImg(7, gPieces[i].cell.column, gPieces[i].cell.row);
		break;
	    case "white-rook":
		drawImg(8, gPieces[i].cell.column, gPieces[i].cell.row);
		break;
	    case "white-bishop":
		drawImg(9, gPieces[i].cell.column, gPieces[i].cell.row);
		break;
	    case "white-knight":
		drawImg(10, gPieces[i].cell.column, gPieces[i].cell.row);
		break;
	    case "white-pawn":
		drawImg(11, gPieces[i].cell.column, gPieces[i].cell.row);
		break;
	}
    }
}

function drawImg(index, column, row){
    var x = column * cCellWidth + cHorzSpacer;
    var y = row * cCellHeight + cVertSpacer;
    gCanvasCtx.drawImage(gImages[index], 0, 0, 64, 64, x, y, cPieceWidth, cPieceHeight);
}

function getCursorPosition(e) {
    /* returns Cell with .row and .column properties */
    var x;
    var y;
    if (e.pageX != undefined && e.pageY != undefined) {
	x = e.pageX;
	y = e.pageY;
    }
    else {
	x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
	y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop;
    }
    x -= gCanvasElement.offsetParent.offsetLeft;
    x -= gCanvasElement.offsetLeft;
    y -= gCanvasElement.offsetTop;
    x = Math.min(x, cBoardWidth * cCellWidth);
    //alert(x/cCellWidth);
    y = Math.min(y, cBoardHeight * cCellHeight);
    var cell = new Cell(Math.floor(y/cCellHeight), Math.floor(x/cCellWidth));
    return cell;
}

function canvasOnClick(e){
    var cell = getCursorPosition(e);
    for (var i = 0; i < gPieces.length; i++) {
	if ((gPieces[i].cell.row == cell.row) &&
	    (gPieces[i].cell.column == cell.column)) {
	    clickOnPiece(i);
	    return;
	}
    }

    clickOnEmptyCell(cell);
    drawBoard();
}

function clickOnPiece(pieceIndex) {
    if (gSelectedPieceIndex == pieceIndex){
	gSelectedPieceIndex = -1;
	drawBoard();
	return;
    }
    gSelectedPieceIndex = pieceIndex;
    gSelectedPieceHasMoved = false;
    drawBoard();
}

function clickOnEmptyCell(cell){
    if(gSelectedPieceIndex == -1) return;

    gPieces[gSelectedPieceIndex].cell.row = cell.row;
    gPieces[gSelectedPieceIndex].cell.column = cell.column;

    gSelectedPieceIndex = -1;
}

$(function(){
    initGame(document.getElementById("game"));
});

function loadImages(){
    gImagesSrc = [
	"images/black-king.png",
	"images/black-queen.png",
	"images/black-rook.png",
	"images/black-bishop.png",
	"images/black-knight.png",
	"images/black-pawn.png",
	"images/white-king.png",
	"images/white-queen.png",
	"images/white-rook.png",
	"images/white-bishop.png",
	"images/white-knight.png",
	"images/white-pawn.png"
    ];
    gImages = [
	new Image(), new Image(), new Image(), new Image(), new Image(), new Image(),
	new Image(), new Image(), new Image(), new Image(), new Image(), new Image()
    ];

    loadImage(gImageLoadIndex);
}

function loadImage(index){
    gImages[index].src = gImagesSrc[index];
    gImages[index].onload = function(){
	gImageLoadIndex++;
	if(gImageLoadIndex >= gImagesSrc.length){
	    gImagesLoaded = true;
	    newGame();
	    return;
	}
	loadImage(gImageLoadIndex);
    }
}