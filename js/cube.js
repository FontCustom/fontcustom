// From: http://www.paulrhayes.com/experiments/cube-3d/touch.html
$(function(){
    
    var el = document.createElement('div'),
        transformProps = 'transform WebkitTransform MozTransform OTransform msTransform'.split(' '),
        transformProp = support(transformProps),
        transitionDuration = 'transitionDuration WebkitTransitionDuration MozTransitionDuration OTransitionDuration msTransitionDuration'.split(' '),
        transitionDurationProp = support(transitionDuration);
        
    function support(props) {
        for(var i = 0, l = props.length; i < l; i++) {
            if(typeof el.style[props[i]] !== "undefined") {
                return props[i];
            }
        }
    }

    var mouse = { 
            start : {}
        },
        touch = document.ontouchmove !== undefined,
        viewport = {
            x: -10, 
            y: 20, 
            el: $('.cube')[0],
            move: function(coords) {
                if(coords) {
                    if(typeof coords.x === "number") this.x = coords.x;
                    if(typeof coords.y === "number") this.y = coords.y;
                }

                this.el.style[transformProp] = "rotateX("+this.x+"deg) rotateY("+this.y+"deg)";
            },
            reset: function() {
                this.move({x: 0, y: 0});
            }
        };
        
    viewport.duration = function() {
        var d = touch ? 50 : 500;
        viewport.el.style[transitionDurationProp] = d + "ms";
        return d;
    }();
    
    $(document).keydown(function(evt) {
        switch(evt.keyCode)
        {   
            case 37: // left
                viewport.move({y: viewport.y - 90});
                break;
            
            case 38: // up
                // evt.preventDefault();
                // viewport.move({x: viewport.x + 90});                
                break;
            
            case 39: // right
                viewport.move({y: viewport.y + 90});
                break;
                
            case 40: // down
                // evt.preventDefault();
                // viewport.move({x: viewport.x - 90});
                break;
                
            case 27: //esc
                viewport.reset();
                break;
                
            default:
                break;
        };  
    });
    
});