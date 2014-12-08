package fr.durss.thermal.utils {
	import flash.display.BitmapData;
	import fr.durss.thermal.vo.GridData;
	import fr.durss.thermal.vo.ZoneData;

	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	
	/**
	 * Registers classes aliases so that the data can be saved as a ByteArray
	 * in a really easy way.
	 * By the way, the method makes sure that all these classes have getters
	 * AND setters for every important property. That way we are sure that 
	 * the data will be restored properly. 
	 * 
	 * @author Francois
	 */
	public function initSerializableClasses():void {
			//Check if the value objects are all serializable and registers aliases
			//so that ByteArray.readObject() can instanciate the value objects.
			var serializableClasses:Array = [Point,
											Rectangle,
											String,
											GridData,
											ByteArray,
											ZoneData];
			var i:int, len:int;
			var j:int, lenJ:int;
			len = serializableClasses.length;
			for (i = 0; i < len; ++i) {
				
				var xml:XML = describeType(serializableClasses[i]);
				var nodes:XMLList = XML(xml.child("factory")[0]).child("accessor");
				var cName:String = String(xml.@name).replace(/.*::(.*)/gi, "$1");
				registerClassAlias(cName, serializableClasses[i]);
				
				//Check getters/setters of every classes but the flash built-in ones.
				if(serializableClasses[i] != Point
				&& serializableClasses[i] != Date
				&& serializableClasses[i] != String) {
					lenJ = nodes.length();
					for(j = 0; j < lenJ; ++j) {
						if(nodes[j].@access != "readwrite") {
							trace("Class "+cName+"'s '"+nodes[j].@name+"' property is '"+nodes[j].@access+"'. Must be 'readwrite'.");
						}
					}
				}
			}
	}
}
