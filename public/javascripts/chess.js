var gCanvasElement;
var gCanvasCtx;
var gPieces;
var gSelectedPieceIndex = -1;
var gSelectedPieceHasMove = false;
var gGameInProgress = false;
var gImages;
var gImagesLoaded = false;
var gImageLoadIndex = 0;
var gImagePath = "../images/"
var gGameId;


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


function initGame(canvasElement, gameId){
    if(!canvasElement)
        return;

    gCanvasElement = canvasElement;
    gCanvasElement.addEventListener("click", canvasOnClick, false);
    gCanvasCtx = gCanvasElement.getContext("2d");

    gGameId = gameId;

    // loadImages will call setupGame() when finished
    loadImages();
}

function setupGame(){
    $.ajaxSetup ({
        cache: false
    });

    $.getJSON('/boards/' + gGameId, function(json){
        // Load all the pieces
        gPieces = [];
	$.each(json, function(i, piece){
	    gPieces.push(new Piece(piece.type, piece.row, piece.column));
	});

	gSelectedPieceIndex = -1;
	gGameInProgress = true;
	drawBoard();
    });
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
    if(!gGameInProgress) return;

    var cell = getCursorPosition(e);
    var pieceIndex = -1;

    // Check to see if a piece was clicked
    for (var i = 0; i < gPieces.length; i++) {
	if ((gPieces[i].cell.row == cell.row) &&
	    (gPieces[i].cell.column == cell.column)) {
	    pieceIndex = i;
	    continue;
	}
    }

    if(gSelectedPieceIndex == pieceIndex){
	// Unselect the piece
	gSelectedPieceIndex = -1;
	drawBoard();
	return;
    } else {
	// Check if gSelectPieceIndex has a value
	if(gSelectedPieceIndex == -1){
	    gSelectedPieceIndex = pieceIndex;
	    drawBoard();
	    return;
	}

	// Attempt a move
	var move = "from_row=" + gPieces[gSelectedPieceIndex].cell.row +
		    "&to_row=" + cell.row +
		    "&from_column=" + gPieces[gSelectedPieceIndex].cell.column +
		    "&to_column=" + cell.column;

	$.ajax({
	    url: '/games/' + gGameId + '/move',
	    data: move,
	    dataType: "json",
	    success: function(json){
		if(!json.result){
		    gPieces[gSelectedPieceIndex].cell.row = json.to_row;
		    gPieces[gSelectedPieceIndex].cell.column = json.to_column;
		    gSelectedPieceIndex = -1;
		    drawBoard();
		}
	    }
	});
    }
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

function loadImages(){
    gImagesSrc = [
	"black-king.png",
	"black-queen.png",
	"black-rook.png",
	"black-bishop.png",
	"black-knight.png",
	"black-pawn.png",
	"white-king.png",
	"white-queen.png",
	"white-rook.png",
	"white-bishop.png",
	"white-knight.png",
	"white-pawn.png"
    ];
    gImages = [
	new Image(), new Image(), new Image(), new Image(), new Image(), new Image(),
	new Image(), new Image(), new Image(), new Image(), new Image(), new Image()
    ];

    loadImage(gImageLoadIndex);
}

function loadImage(index){
    gImages[index].src = gImagePath + gImagesSrc[index];
    gImages[index].onload = function(){
	gImageLoadIndex++;
	if(gImageLoadIndex >= gImagesSrc.length){
	    gImagesLoaded = true;
	    setupGame();
	    return;
	}
	loadImage(gImageLoadIndex);
    }

    gImages[index].onerror = function(){
	$('#status').html('Error loading images');
    }
}