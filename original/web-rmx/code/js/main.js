$(function(){

    var sprites = new Array();

    $('.m1').each(function(){
        var that = $(this);
        sprites.push({
            sprite:that,
            velocity:-3,
            posx:0,
            posy:0
        });
    });

    $('.m2').each(function(){
        var that = $(this);
        sprites.push({
            sprite:that,
            velocity:-5,
            posx:0,
            posy:0
        });
    });

    $('.m3').each(function(){
        var that = $(this);
        sprites.push({
            sprite:that,
            velocity:-7,
            posx:0,
            posy:0
        });
    });

    $('.p1').each(function(){
        var that = $(this);
        sprites.push({
            sprite:that,
            velocity:3,
            posx:0,
            posy:0
        });
    });

    $('.p2').each(function(){
        var that = $(this);
        sprites.push({
            sprite:that,
            velocity:7,
            posx:0,
            posy:0
        });
    });

    function parallex(xperc,yperc) {

        for(var i=0;i<sprites.length;i++) {
            //sprites[i].newX = sprites[i].posx-Math.round(sprites[i].velocity/100*xperc);
            var sprite = sprites[i].sprite;
            //if (mobile) {
            //    sprite.css('-webkit-transform', 'translateX(' + (sprites[i].posx-Math.round(sprites[i].velocity/100*xperc)) + 'px)');
            //} else {
            sprite.css({marginLeft:sprites[i].posx-Math.round(sprites[i].velocity/100*xperc)});
            //}
        }
    }

    // device rotation detection
    //console.log(window.DeviceMotionEvent);
    if (window.DeviceMotionEvent != undefined && window.ondevicemotion != undefined) {

        var x = 0, y = 0, vx = 0, vy = 0, ax = 0, ay = 0;

        window.ondevicemotion = function(e) {
            ax = event.accelerationIncludingGravity.x * 50;
            ay = event.accelerationIncludingGravity.y * 50;
        }

        setInterval(function() {
            var landscapeOrientation = window.innerWidth/window.innerHeight > 1;
            if (landscapeOrientation) {
                vx = ay//vx + ay;
                vy = ax//vy + ax;
            } else {
                vy = -ay//vy - ay;
                vx = -ax//vx + ax;
            }
            vx = vx * 0.98;
            vy = vy * 0.98;
            y = parseInt(y + vy);// / 50);
            x = parseInt(x + vx);// / 50);

            // change vx/vy in negative for bumping..
            if (x<=-100) { x = -100; }//vx = -vx; }
            if (y<=-100) { y = -100; }//vy = -vy; }
            if (x>=100) { x = 100; }//vx = -vx; }
            if (y>=100) { y = 100; }//vy = -vy; }

            //$('#footer').text('top:'+y+' left:'+x);
            parallex(x,0);

        }, 25);
    }

    else {

        // browser mouse detection
        $("#container").mousemove(function(event) {
            var width = $(window).width();
            var xperc = (50-Math.round((event.pageX/width)*100))*2;
            parallex(xperc,0);
        });
    }
});