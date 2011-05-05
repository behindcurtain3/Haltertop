function Chess(canvasElement, gameId, playerColor){
    // Canvas
    this.canvasElement = canvasElement;
    this.canvasCtx = null;

    // Game
    this.gameId = gameId;
    this.playerColor = playerColor;
    this.gameInProgress = false;
    this.pieces = [];
    this.selectedPieceIndex = -1;
    this.selectedPieceHasMoved = false;

    // Drawing
    this.canvasValid = true;
    this.interval = 50;
    this.boardWidth = 8;
    this.boardHeight = 8;
    this.pieceWidth = 48;
    this.pieceHeight = 48;
    this.cellWidth = 64;
    this.cellHeight = 64;
    this.horzSpacer = (this.cellWidth - this.pieceWidth) / 2;
    this.vertSpacer = (this.cellHeight - this.pieceHeight) / 2;
    this.colorDark = "#f4a460";
    this.colorLight = "#fff";
    this.colorHighlight = "#6267f4";

}

Chess.prototype = {
    init: function(){
	this.canvasCtx = this.canvasElement.getContext("2d");
	this.canvasElement.onselectstart = function() { return false; }

	var that = this;
	$.getJSON('/boards/' + this.gameId, function(json){
	    // Load all the pieces
	    that.pieces = [];
	    $.each(json, function(i, piece){
		that.pieces.push(new Piece(piece.color, piece.type, piece.row, piece.column));
	    });

	    that.selectedPieceIndex = -1;
	    that.gameInProgress = true;
	    that.invalidate();
	});
    },

    draw: function(){
	var self = this;
	if(self.canvasValid) return;

	// Clear the canvas
	self.canvasCtx.clearRect(0, 0, 512, 512);

	// Tracks whether to draw a black or white square
	var blackSquare = true;

	// Draw the board
	for(var y = 0; y < self.boardHeight; y++){
	  for(var x = 0; x < self.boardWidth; x++){
	    if(self.selectedPieceIndex != -1){
		if(self.pieces[self.selectedPieceIndex].cell.row == y && self.pieces[self.selectedPieceIndex].cell.column == x){
		    self.canvasCtx.fillStyle = self.colorHighlight;
		} else {
		    self.canvasCtx.fillStyle = (blackSquare) ? self.colorLight : self.colorDark;
		}
	    } else {
		self.canvasCtx.fillStyle = (blackSquare) ? self.colorLight : self.colorDark;
	    }
	    self.canvasCtx.fillRect(x * self.cellWidth, y * self.cellHeight, self.cellWidth, self.cellHeight);
	    blackSquare = !blackSquare;
	  }
	  blackSquare = !blackSquare;
	}

	// Draw board border
	self.canvasCtx.moveTo(0,0);
	self.canvasCtx.lineTo(512,0);
	self.canvasCtx.lineTo(512,512);
	self.canvasCtx.lineTo(0,512);
	self.canvasCtx.lineTo(0,0);
	self.canvasCtx.strokeStyle = "#999";
	self.canvasCtx.stroke();

	// Draw pieces
	var index = -1;
	for(var i = 0; i < self.pieces.length; i++){
	    switch(self.pieces[i].color){
		case "black":
		    switch(self.pieces[i].type){
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
		    switch(self.pieces[i].type){
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
	    }
	    self.drawImg(index, self.pieces[i].cell.column, self.pieces[i].cell.row);
	}
	self.canvasValid = true;
    },

    drawImg: function(index, column, row){
	var x = column * this.cellWidth + this.horzSpacer;
	var y = row * this.cellHeight + this.vertSpacer;
	this.canvasCtx.drawImage(gImages[index], 0, 0, 64, 64, x, y, this.pieceWidth, this.pieceHeight);
    },

    canvasOnClick: function(e){
	if(!this.gameInProgress) return;

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
		    if(!json.result){
			that.pieces[this.selectedPieceIndex].cell.row = json.to_row;
			that.pieces[this.selectedPieceIndex].cell.column = json.to_column;
			
		    } else {
			$.gritter.add({
			    title: 'Ah ah ah',
			    text: json.result
			});
		    }
		    that.selectedPieceIndex = -1;
		    that.invalidate();
		}
	    });
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