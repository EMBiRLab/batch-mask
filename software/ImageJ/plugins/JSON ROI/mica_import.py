from com.xhaus.jyson import JysonCodec as json
from ij.plugin.frame import RoiManager
from ij.io import OpenDialog
from ij.gui import Roi, PolygonRoi
import sys

def get_roi(data):
    if data['type'] == 'polygon':
        return PolygonRoi(data['x'], data['y'], data['count'], Roi.POLYGON)

    elif data['type'] == 'composite':
        comp_rois = []
        count = data['count']
        last = count - 1
        for i in range(count):
            comp_rois.append(get_roi(data['rois'][i]))

        roi = ShapeRoi(comp_rois[last])
        
        for j in range(last):
            roi.not(ShapeRoi(comp_rois[j]))
        return roi

    elif data['type'] == 'line':
        return Line(data['x1'], data['y1'], data['x2'], data['y2'])


rm = RoiManager.getInstance()

if rm:
    directory = "C:/Users/timre/Desktop/tutorial set/" # SET DATASET PATH HERE
    imp = IJ.getImage()
    name = directory + imp.title[:-4] + '.json'
    file = open(name,'r')
    read = file.read()
    data = json.loads(read)
    rm.reset()

    for i in range(data['count']):
        rm.addRoi(get_roi(data['rois'][i]))
        rm.rename(i, data['classes'][i])
    file.close()
else:
    print("No roi manager open")
