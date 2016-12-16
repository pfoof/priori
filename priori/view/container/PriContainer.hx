package priori.view.container;

import priori.style.border.PriBorderStyle;
import jQuery.JQuery;
import priori.geom.PriGeomBox;
import priori.event.PriEvent;

class PriContainer extends PriDisplay {

    private var _childList:Array<PriDisplay> = [];
    private var _migratingView:Bool = false;

    @:isVar public var numChildren(get, null):Int;

    public function new() {
        super();
    }

    @:noCompletion private function get_numChildren():Int {
        return this._childList.length;
    }

    public function getChild(index:Int):PriDisplay {
        var result:PriDisplay = null;

        if (index < this._childList.length) {
            result = this._childList[index];
        }

        return result;
    }

    public function addChildList(childList:Array<Dynamic>):Void {
        var i:Int = 0;
        var n:Int = childList.length;

        while (i < n) {
            if (Std.is(childList[i], PriDisplay)) this.addChild(childList[i]);
            i++;
        }
    }

    public function removeChildList(childList:Array<Dynamic>):Void {
        var i:Int = 0;
        var n:Int = childList.length;

        while (i < n) {
            if (Std.is(childList[i], PriDisplay)) this.removeChild(childList[i]);
            i++;
        }
    }

    public function addChild(child:PriDisplay):Void {

        // remove o objeto de algum parent, caso ja tenha algum
        child.removeFromParent();

        this._childList.push(child);
        this._jselement.appendChild(child.getJSElement());

        child._parent = this;

        if (this.hasApp()) {
            if (this.disabled) {
                child.getElement().attr("disabled", "disabled");
                child.getElement().find("*").attr("disabled", "disabled");
            } else {
                if (!this.hasDisabledParent()) {
                    child.getElement().removeAttr("disabled");
                    child.getElement().find("*").not("*[priori-disabled='disabled'], *[priori-disabled='disabled'] *").removeAttr("disabled");
                }
            }
        }

        if (child.hasApp()) {
            child.dispatchEvent(new PriEvent(PriEvent.ADDED_TO_APP, true));
        }

        child.dispatchEvent(new PriEvent(PriEvent.ADDED, true));
    }

    public function removeChild(child:PriDisplay):Void {
        // verifica se a view é filha deste container
        if (this == child.parent) {

            // verifica se a view ja esta no app
            var viewHasAppBefore:Bool = child.hasApp();

            this._childList.remove(child);
            this._jselement.removeChild(child.getJSElement());
            //child.getElement().remove();

            child._parent = null;

            if (viewHasAppBefore) {
                child.dispatchEvent(new PriEvent(PriEvent.REMOVED_FROM_APP, true));
            }

            child.dispatchEvent(new PriEvent(PriEvent.REMOVED, true));
        }
    }

    override public function kill():Void {
        var i:Int;
        var n:Int;

        var childListCopy:Array<PriDisplay> = this._childList.copy();

        i = 0;
        n = childListCopy.length;

        while (i < n) {
            childListCopy[i].kill();
            i++;
        }

        childListCopy = null;

        this._childList = [];

        super.kill();
    }

    public function getContentBox():PriGeomBox {
        var result:PriGeomBox = new PriGeomBox();

        var i:Int = 0;
        var n:Int = this.numChildren;

        while (i < n) {

            result.x = Math.min(result.x, this.getChild(i).x);
            result.y = Math.min(result.y, this.getChild(i).y);

            result.width = Math.max(result.width, this.getChild(i).maxX);
            result.height = Math.max(result.height, this.getChild(i).maxY);

            i++;
        }

        return result;
    }

    @:noCompletion override private function set_width(value:Float):Float {
        if (value != this.width) {
            super.set_width(value);
            this.dispatchEvent(new PriEvent(PriEvent.RESIZE, false));
        }

        this.updateBorderDisplay();

        return value;
    }

    @:noCompletion override private function set_height(value:Float):Float {
        if (value != this.height) {
            super.set_height(value);
            this.dispatchEvent(new PriEvent(PriEvent.RESIZE, false));
        }

        this.updateBorderDisplay();

        return value;
    }
}
