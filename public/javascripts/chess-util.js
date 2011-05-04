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
	    return;
	}
	loadImage(gImageLoadIndex);
    }

    gImages[index].onerror = function(){
	$('#status').html('Error loading images');
    }
}