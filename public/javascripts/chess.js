function Chess(canvasElement, gameId, playerColor){
    // Canvas
    this.canvasElement = canvasElement;
    this.canvasCtx = null;

    // Game
    this.gameId = gameId;
    this.playerColor = playerColor;
    this.yourturn = false;
    this.gameInProgress = false;
    this.pieces = [];
    this.selectedPieceIndex = -1;
    this.numMoves = 0;

    // Animating piece moves
    this.targetTime = 750;
    this.targetTimeElapsed = -1;

    // Sound
    this.moveSfx = document.createElement("audio");
    this.moveSfx.src = "../audio/Randomize3.mp3";

    // Drawing
    this.canvasValid = true;
    this.animating = false;
    this.interval = 50;
    this.inverted = false;
    this.invertForwards = [0,1,2,3,4,5,6,7];
    this.invertBackwards = [7,6,5,4,3,2,1,0];

    // Display variables
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
	
	this.canvasElement.onselectstart = function() {return false;}

    },

    loadPieces: function(){
	var that = this;
	$.getJSON('/games/' + this.gameId + '/pieces', function(json){
	    // Load all the pieces
	    that.pieces = [];

	    $.each(json, function(i, p){
		var row = p.position.row;
		var column = p.position.col;
		if(that.inverted){
		    row = that.invert(row, true);
		    column = that.invert(column, true);
		}
		that.pieces.push(new Piece(p.color, p.name, row, column));
	    });

	    that.selectedPieceIndex = -1;
	    that.gameInProgress = true;
	    that.invalidate();

            $(document).oneTime(that.interval, "loop", function(){
                that.loop();
            });
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

	// Tracks whether to draw a light or dark square in the upper left
	var darkSquare = false;

	// Draw the board
	for(var y = 0; y < this.boardHeight; y++){
	  for(var x = 0; x < this.boardWidth; x++){
	    if(this.selectedPieceIndex != -1){
		if(this.pieces[this.selectedPieceIndex].cell.row == y && this.pieces[this.selectedPieceIndex].cell.column == x){
		    this.canvasCtx.fillStyle = this.colorHighlight;
		} else {
		    this.canvasCtx.fillStyle = (darkSquare) ? this.colorDark : this.colorLight;
		}
	    } else {
		this.canvasCtx.fillStyle = (darkSquare) ? this.colorDark : this.colorLight;
	    }
	    this.canvasCtx.fillRect(x * this.cellWidth, y * this.cellHeight, this.cellWidth, this.cellHeight);
	    darkSquare = !darkSquare;
	  }
	  darkSquare = !darkSquare;
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
            // A piece was clicked, if it is the players own, switch the selectedPieceIndex
            if(pieceIndex != -1){
                if(this.pieces[pieceIndex].color == this.playerColor){
                    this.selectedPieceIndex = pieceIndex;
                    this.invalidate();
                    return;
                }
                if(this.selectedPieceIndex == -1){
                    return; // don't allow a user to select an opponenets piece
                }
            }
            // If no piece is selected, select one
	    if(this.selectedPieceIndex == -1){
		this.selectedPieceIndex = pieceIndex;
		this.invalidate();
		return;
	    }

	    // Attempt a move
	    var move = "type=standard";
	    if(this.inverted){
		move += "&fr=" + this.invert(this.pieces[this.selectedPieceIndex].cell.row, true) +
			"&tr=" + this.invert(cell.row, true) +
			"&fc=" + this.invert(this.pieces[this.selectedPieceIndex].cell.column, true) +
			"&tc=" + this.invert(cell.column, true);
	    } else {
		move += "&fr=" + this.pieces[this.selectedPieceIndex].cell.row +
			"&tr=" + cell.row +
			"&fc=" + this.pieces[this.selectedPieceIndex].cell.column +
			"&tc=" + cell.column;
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

            for(var x = 0; x < move.length; x++){

                var indexToSplice = -1;
                if(that.inverted){
                    move[x].from.row = that.invert(move[x].from.row, true);
                    move[x].to.row = that.invert(move[x].to.row, true);
                    move[x].from.col = that.invert(move[x].from.col, true);
                    move[x].to.col = that.invert(move[x].to.col, true);
                }
                for(var i = 0; i < that.pieces.length; i++){
                    if(that.pieces[i].cell.column == move[x].from.col && that.pieces[i].cell.row == move[x].from.row){
                        that.pieces[i].moving = true;
                        that.pieces[i].target = new Cell(move[x].to.row, move[x].to.col)
                        that.targetTimeElapsed = 0;
                        that.selectedPieceIndex = -1;
			that.invalidate();
                    }
                }
                
            }
	});
        this.pieces.sort(this.sortpieces);
	this.moveSfx.play();
    },

    capture: function(piece){
        if(!piece)
            return;

        if(this.inverted){
            piece.at.col = this.invert(piece.at.col, true);
            piece.at.row = this.invert(piece.at.row, true)
        }

        var indexToSplice = -1;
        for(var i = 0; i < this.pieces.length; i++){
            if(this.pieces[i].cell.column == piece.at.col && this.pieces[i].cell.row == piece.at.row){
                indexToSplice = i;
            }
        }
        
        if(indexToSplice != -1){
            this.pieces.splice(indexToSplice, 1);
        }
    },

    set: function(data){
	if(!data)
	    return;

	if(this.inverted){
            data.position.col = this.invert(data.position.col, true);
            data.position.row = this.invert(data.position.row, true)
        }

	for(var i = 0; i < this.pieces.length; i++){
	    if(this.pieces[i].target == null)
		continue;
	    if(this.pieces[i].target.column == data.position.col && this.pieces[i].target.row == data.position.row){
		this.pieces[i].type = data.type;
		this.invalidate();
	    }
	}
    },

    turn: function(t){
	if(this.playerColor == t){
	    this.yourturn = true;
	} else {
	    this.yourturn = false;
	}

	if(t == "white"){
            $('#white').addClass("highlight", 1000);
            $('#black').removeClass("highlight", 1000);

	    $('#black-move').fadeOut();
	    $('#white-move').fadeIn();
	} else {
            $('#black').addClass("highlight", 1000);
            $('#white').removeClass("highlight", 1000);

	    $('#black-move').fadeIn();
	    $('#white-move').fadeOut();
	}
    },

    askForPromotion: function(color){
	if(this.playerColor != color)
	    return;

	var that = this;

	$('#promotion').modal();
	if(color == "white"){
	    $('#white_pieces').show();
	    $('#promote_white_queen').click(function(){
		that.sendPromotion('queen');
	    });
	    $('#promote_white_rook').click(function(){
		that.sendPromotion('rook');
	    });
	    $('#promote_white_bishop').click(function(){
		that.sendPromotion('bishop');
	    });
	    $('#promote_white_knight').click(function(){
		that.sendPromotion('knight');
	    });
	} else {
	    $('#black_pieces').show();
	    $('#promote_black_queen').click(function(){
		that.sendPromotion('queen');
	    });
	    $('#promote_black_rook').click(function(){
		that.sendPromotion('rook');
	    });
	    $('#promote_black_bishop').click(function(){
		that.sendPromotion('bishop');
	    });
	    $('#promote_black_knight').click(function(){
		that.sendPromotion('knight');
	    });
	    
	}
    },

    sendPromotion: function(type){
	var move = "type=promotion&to=" + type;
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
    },

    sortpieces: function(a, b){
        if((a.moving && b.moving) || (!a.moving && !b.moving))
            return 0;
        else if(a.moving && !b.moving)
            return 1;
        else
            return -1;
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