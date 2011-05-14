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
    this.inverted = false;
    this.invertForwards = [0,1,2,3,4,5,6,7];
    this.invertBackwards = [7,6,5,4,3,2,1,0];

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
		var row = p.piece.row;
		var column = p.piece.column;
		if(that.inverted){
		    row = that.invert(row, true);
		    column = that.invert(column, true);
		}
		that.pieces.push(new Piece(p.piece.color, p.piece.name, row, column));
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

        this.canvasValid = true;
        this.targetTimeElapsed += this.interval;

	// Clear the canvas
	this.canvasCtx.clearRect(0, 0, this.canvasElement.width, this.canvasElement.height);

	// Tracks whether to draw a black or white square in the upper left
	var blackSquare = !this.inverted;

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
	    if(this.pieces[i].moving){
		// Calculate the position of the piece by interpolating based on time
		var percent = this.targetTimeElapsed / this.targetTime;

    		if(percent > 1) percent = 1;

		var x = this.translateColumn(this.pieces[i].cell.column);
		var y = this.translateRow(this.pieces[i].cell.row);
		var xToAdd = (this.translateColumn(this.pieces[i].target.column) - x) * percent;
		var yToAdd = (this.translateRow(this.pieces[i].target.row) - y) * percent;

		x += xToAdd;
		y += yToAdd;

		this.drawImgAt(index, x, y);

		if(this.targetTimeElapsed >= this.targetTime){
		    this.pieces[i].cell =  this.pieces[i].target;
		    this.pieces[i].moving = false;
                    this.pieces[i].target = null;
		}
                this.canvasValid = false;
	    } else {
		this.drawImg(index, this.pieces[i].cell.column, this.pieces[i].cell.row);
	    }
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
	    var move;
	    if(this.inverted){
		move = "from_row=" + this.invert(this.pieces[this.selectedPieceIndex].cell.row, true) +
			"&to_row=" + this.invert(cell.row, true) +
			"&from_column=" + this.invert(this.pieces[this.selectedPieceIndex].cell.column, true) +
			"&to_column=" + this.invert(cell.column, true);
	    } else {
		move = "from_row=" + this.pieces[this.selectedPieceIndex].cell.row +
			"&to_row=" + cell.row +
			"&from_column=" + this.pieces[this.selectedPieceIndex].cell.column +
			"&to_column=" + cell.column;
	    }

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
	var that = this;
	$.each(json, function(i, move){
	    if(!$.isArray(move))
		return true;
            console.log(move);
            for(var x = 0; x < move.length; x++){

                var indexToSplice = -1;
                if(that.inverted){
                    move[x].from_row = that.invert(move[x].from_row, true);
                    move[x].to_row = that.invert(move[x].to_row, true);
                    move[x].from_column = that.invert(move[x].from_column, true);
                    move[x].to_column = that.invert(move[x].to_column, true);
                }
                for(var i = 0; i < that.pieces.length; i++){
                    if(that.pieces[i].cell.column == move[x].to_column && that.pieces[i].cell.row == move[x].to_row){
                        indexToSplice = i;
                    }

                    if(that.pieces[i].cell.column == move[x].from_column && that.pieces[i].cell.row == move[x].from_row){
                        that.pieces[i].moving = true;
                        that.pieces[i].target = new Cell(move[x].to_row, move[x].to_column)
                        //that.movingPiece = that.pieces[i];
                        //that.targetCell = new Cell(move[x].to_row, move[x].to_column);
                        that.targetTimeElapsed = 0;
                        that.selectedPieceIndex = -1;
                        that.invalidate();
                    }
                }
                if(indexToSplice != -1){
                    that.pieces.splice(indexToSplice, 1);
                }
            }
	});
    },

    turn: function(t){
	if(this.playerColor == t){
	    this.yourturn = true;
	} else {
	    this.yourturn = false;
	}

	if(t == "white"){
	    $('#black-move').fadeOut();
	    $('#white-move').fadeIn();
	} else {
	    $('#black-move').fadeIn();
	    $('#white-move').fadeOut();
	}
    },

    getCursorPosition: function(e){
	var totalOffsetX = 0;
        var totalOffsetY = 0;
        var canvasX = 0;
        var canvasY = 0;
        var currentElement = this.canvasElement;

        do{
            totalOffsetX += currentElement.offsetLeft;
            totalOffsetY += currentElement.offsetTop;
        }
        while(currentElement = currentElement.offsetParent)

        canvasX = event.pageX - totalOffsetX;
        canvasY = event.pageY - totalOffsetY;
        return new Cell( Math.floor( canvasY / this.cellHeight ), Math.floor( canvasX / this.cellWidth ) );
    },

    invalidate: function(){
	this.canvasValid = false;
    },

    invert: function(n, dir){
	if(dir){
	    return this.invertBackwards[n];
	} else {
	    return this.invertForwards[n];
	}
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
    this.target = null;
    this.moving = false;
}