function Chess(canvasElement, gameId, playerColor){
    // Canvas
    this.canvasElement = canvasElement;
    this.canvasCtx = null;

    // Game
    this.gameId = gameId;
    this.playerColor = playerColor;
    this.yourmove = false;
    this.gameInProgress = false;
    this.pieces = [];
    this.selectedPieceIndex = -1;

    // Animating piece moves
    this.movingPiece = null;
    this.targetCell = new Cell(-1,-1);
    this.targetTime = 750;
    this.targetTimeElapsed = -1;

    // Drawing
    this.canvasValid = true;
    this.interval = 50;
    this.ajaxInterval = 2000;
    this.ajaxTimeElapsed = 0;
    this.boardWidth = 8;
    this.boardHeight = 8;
    this.pieceWidth = 48;
    this.pieceHeight = 48;
    this.cellWidth = 64;
    this.cellHeight = 64;
    this.horzSpacer = 8;
    this.vertSpacer = 8;
    this.colorDark = "#f4a460";
    this.colorLight = "#fff";
    this.colorHighlight = "#6267f4";

}

Chess.prototype = {
    init: function(){
	this.canvasCtx = this.canvasElement.getContext("2d");

	this.cellWidth = this.canvasElement.width / this.boardWidth;
	this.cellHeight = this.canvasElement.height / this.boardHeight;

	this.pieceWidth = this.cellWidth * 0.75;
	this.pieceHeight = this.cellHeight * 0.75;

	this.horzSpacer = (this.cellWidth - this.pieceWidth) / 2;
	this.vertSpacer = (this.cellHeight - this.pieceHeight) / 2;
	
	this.canvasElement.onselectstart = function() { return false; }

	var that = this;
	$.getJSON('/games/' + this.gameId + '/pieces', function(json){
	    // Load all the pieces
	    that.pieces = [];
	    $.each(json, function(i, p){
		that.pieces.push(new Piece(p.piece.color, p.piece.name, p.piece.row, p.piece.column));
	    });

	    that.selectedPieceIndex = -1;
	    that.gameInProgress = true;
	    that.invalidate();
	});
    },

    loop: function(){
	this.draw();
    },

    draw: function(){
	if(this.canvasValid) return;

	// Clear the canvas
	this.canvasCtx.clearRect(0, 0, this.canvasElement.width, this.canvasElement.height);

	// Tracks whether to draw a black or white square
	var blackSquare = true;

	// Draw the board
	for(var y = 0; y < this.boardHeight; y++){
	  for(var x = 0; x < this.boardWidth; x++){
	    if(this.selectedPieceIndex != -1){
		if(this.pieces[this.selectedPieceIndex].cell.row == y && this.pieces[this.selectedPieceIndex].cell.column == x){
		    this.canvasCtx.fillStyle = this.colorHighlight;
		} else {
		    this.canvasCtx.fillStyle = (blackSquare) ? this.colorLight : this.colorDark;
		}
	    } else {
		this.canvasCtx.fillStyle = (blackSquare) ? this.colorLight : this.colorDark;
	    }
	    this.canvasCtx.fillRect(x * this.cellWidth, y * this.cellHeight, this.cellWidth, this.cellHeight);
	    blackSquare = !blackSquare;
	  }
	  blackSquare = !blackSquare;
	}

	// Draw board border
	this.canvasCtx.moveTo(0,0);
	this.canvasCtx.lineTo(this.canvasElement.width,0);
	this.canvasCtx.lineTo(this.canvasElement.width, this.canvasElement.height);
	this.canvasCtx.lineTo(0, this.canvasElement.height);
	this.canvasCtx.lineTo(0,0);
	this.canvasCtx.strokeStyle = "#000";
	this.canvasCtx.stroke();

	// Draw pieces
	var index = -1;
	for(var i = 0; i < this.pieces.length; i++){
	    switch(this.pieces[i].color){
		case "black":
		    switch(this.pieces[i].type){
			case "king":
			    index = 0;
			    break;
			case "queen":
			    index = 1;
			    break;
			case "rook":
			    index = 2;
			    break;
			case "bishop":
			    index = 3;
			    break;
			case "knight":
			    index = 4;
			    break;
			case "pawn":
			    index = 5;
			    break;
		    }
		    break;
		case "white":
		    switch(this.pieces[i].type){
			case "king":
			    index = 6;
			    break;
			case "queen":
			    index = 7;
			    break;
			case "rook":
			    index = 8;
			    break;
			case "bishop":
			    index = 9;
			    break;
			case "knight":
			    index = 10;
			    break;
			case "pawn":
			    index = 11;
			    break;
		    }
		    break;
                default:
                    index = 0;
                    break;
	    }
	    if(this.movingPiece == this.pieces[i]){
		// Calculate the position of the piece by interpolating based on time
		this.targetTimeElapsed += this.interval;
		var percent = this.targetTimeElapsed / this.targetTime;

    		if(percent > 1) percent = 1;

		var x = this.translateColumn(this.movingPiece.cell.column);
		var y = this.translateRow(this.movingPiece.cell.row);
		var xToAdd = (this.translateColumn(this.targetCell.column) - x) * percent;
		var yToAdd = (this.translateRow(this.targetCell.row) - y) * percent;

		x += xToAdd;
		y += yToAdd;

		this.drawImgAt(index, x, y);

		if(this.targetTimeElapsed >= this.targetTime){
		    this.pieces[i].cell =  this.targetCell;
		    this.movingPiece = null;
		}
	    } else {
		this.drawImg(index, this.pieces[i].cell.column, this.pieces[i].cell.row);
	    }
	}
	if(this.movingPiece == null){
	    this.canvasValid = true;
	}
    },

    drawImg: function(index, column, row){
	var x = this.translateColumn(column);
	var y = this.translateRow(row);
	this.canvasCtx.drawImage(gImages[index], 0, 0, gImages[index].width, gImages[index].height, x, y, this.pieceWidth, this.pieceHeight);
    },

    drawImgAt: function(index, x, y){
	this.canvasCtx.drawImage(gImages[index], 0, 0, gImages[index].width, gImages[index].height, x, y, this.pieceWidth, this.pieceHeight);
    },

    translateColumn: function(column){
	return column * this.cellWidth + this.horzSpacer;
    },

    translateRow: function(row){
	return row * this.cellHeight + this.vertSpacer;
    },

    canvasOnClick: function(e){
	if(!this.gameInProgress || !this.yourturn) return;

	var cell = this.getCursorPosition(e);
	var pieceIndex = -1;

	// Check to see if a piece was clicked
	for (var i = 0; i < this.pieces.length; i++) {
	    if ((this.pieces[i].cell.row == cell.row) &&
		(this.pieces[i].cell.column == cell.column)) {
		pieceIndex = i;
		continue;
	    }
	}

	if(this.selectedPieceIndex == pieceIndex){
	    // Unselect the piece
	    this.selectedPieceIndex = -1;
	    this.invalidate();
	    return;
	} else {
	    // Check if gSelectPieceIndex has a value
	    if(this.selectedPieceIndex == -1){
		if(this.pieces[pieceIndex].color != this.playerColor){
		    return;
		}
		this.selectedPieceIndex = pieceIndex;
		this.invalidate();
		return;
	    }

	    // Attempt a move
	    var move = "from_row=" + this.pieces[this.selectedPieceIndex].cell.row +
			"&to_row=" + cell.row +
			"&from_column=" + this.pieces[this.selectedPieceIndex].cell.column +
			"&to_column=" + cell.column;

	    var that = this;
	    $.ajax({
		url: '/games/' + this.gameId + '/move',
		data: move,
		dataType: "json",
                success: function(json){
                    if(json.status != "success"){
                        $.gritter.add({
                           title: json.title,
                           text: json.text
                        });
                    }
                }
	    });
	}
    },

    move: function(json){
        var indexToSplice = -1;
	for(var i = 0; i < this.pieces.length; i++){
            if(this.pieces[i].cell.column == json.to_column && this.pieces[i].cell.row == json.to_row && json.capture){
                indexToSplice = i;
            }

	    if(this.pieces[i].cell.column == json.from_column && this.pieces[i].cell.row == json.from_row){
                this.movingPiece = this.pieces[i];
		this.targetCell = new Cell(json.to_row, json.to_column);
		this.targetTimeElapsed = 0;
		this.selectedPieceIndex = -1;
		this.invalidate();
	    }
	}
        if(indexToSplice != -1){
            this.pieces.splice(indexToSplice, 1);
        }
    },

    turn: function(t){
	if(this.playerColor == t){
	    this.yourturn = true;
	} else {
	    this.yourturn = false;
	}
    },

    getCursorPosition: function(e){
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
	x -= this.canvasElement.offsetParent.offsetLeft;
	x -= this.canvasElement.offsetLeft;
	y -= this.canvasElement.offsetTop;

	x = Math.min(x, this.boardWidth * this.cellWidth);
	y = Math.min(y, this.boardHeight * this.cellHeight);

	var cell = new Cell( Math.floor( y / this.cellHeight ), Math.floor( x / this.cellWidth ) );
	return cell;
    },

    invalidate: function(){
	this.canvasValid = false;
    }
}

function Cell(row, column){
    this.row = row;
    this.column = column;
}


function Piece(color, type, row, column){
    this.color = color;
    this.type = type;
    this.cell = new Cell(row, column);
}