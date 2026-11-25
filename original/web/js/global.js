$(function(){

    var sprites = new Array();

// front
    $('.p1').each(function(){
        var that = $(this);
        sprites.push({
            sprite:that,
            velocity:15,
            posx:that.position().left,
            posy:that.position().top
        });
    });

// middle
    $('.p2').each(function(){
        var that = $(this);
        sprites.push({
            sprite:that,
            velocity:5,
            posx:that.position().left,
            posy:that.position().top
        });
    });

// background
    $('.p3').each(function(){
        var that = $(this);
        sprites.push({
            sprite:that,
            velocity:-5,
            posx:that.position().left,
            posy:that.position().top
        });
    });

    function parallex(xperc,yperc) {

        for(var i=0;i<sprites.length;i++) {
            //sprites[i].newX = sprites[i].posx-Math.round(sprites[i].velocity/100*xperc);
            var sprite = sprites[i].sprite;
            //if (mobile) {
            //    sprite.css('-webkit-transform', 'translateX(' + (sprites[i].posx-Math.round(sprites[i].velocity/100*xperc)) + 'px)');
            //} else {
            sprite.css({left:sprites[i].posx-Math.round(sprites[i].velocity/100*xperc)});
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
        $("#wrapper").mousemove(function(event) {
            var width = $(window).width();
            var height = $(window).height();
            var xperc = (50-Math.round((event.pageX/width)*100))*2;
            parallex(xperc,0);
        });
    }

    // coda sliding..
    $('#coda-slider').codaSlider({
        dynamicTabs: false,
        crossLinking: false
    });

    // lazy load images..saf
    for (var i=2;i<=7;i++) {
        $('#coda-slider .panel:nth-child(' + i + ') .panel-wrapper').html('<img src="images/screenshot' + i + '.png" title="Screenshot" class="screenshot" width="485" height="323"/>');
    }

    // twitter feed
    $("#txt-right div.txt-wrapper").tweet({
        join_text: "auto",
        username: "Herbert_Fly",
        count: 5,
        avatar_size: 48,
        template: "{avatar} {text} <br/><span class='meta'>[ {time} ]</span>",
        loading_text: "loading news..."
    });

    // rollover
    $('.bugs_birdy-png').hover(function(e){
        $(this).toggleClass('bugs_birdy_rollover-png');
    }).bind('touchstart', function(e){
        e.stopPropagation();
        e.preventDefault();
        $(this).addClass('bugs_birdy_rollover-png');
    }).bind('touchend', function(e){
        e.stopPropagation();
        e.preventDefault();
        $(this).removeClass('bugs_birdy_rollover-png');
    });

    $('.display_nav_left-png').hover(function(e){
        $(this).toggleClass('display_nav_left_rollover-png');
    }).bind('touchstart', function(e){
        $(this).addClass('display_nav_left_rollover-png');
    }).bind('touchend', function(e){
        $(this).removeClass('display_nav_left_rollover-png');
    });

    $('.display_nav_right-png').hover(function(e){
        $(this).toggleClass('display_nav_right_rollover-png');
    }).bind('touchstart', function(e){
        $(this).addClass('display_nav_right_rollover-png');
    }).bind('touchend', function(e){
        $(this).removeClass('display_nav_right_rollover-png');
    });
});