from com.xhaus.jyson import JysonCodec as json
from ij import IJ
from ij.plugin.frame import RoiManager
from ij.io import SaveDialog
from ij.gui import Roi, PolygonRoi

def add_roi(data, roi):
    roi_type = roi.getType()
    if roi_type == Roi.POLYGON:
        data['type'] = 'polygon'
        data['x'] = []
        data['y'] = []
        x = roi.getXCoordinates()
        y = roi.getYCoordinates()
        count = roi.getNCoordinates()
        data['count'] = count
        for i in range(0, count):
            data['x'].append(x[i] + roi.getBounds().x)
            data['y'].append(y[i] + roi.getBounds().y)

    elif roi_type == Roi.COMPOSITE:
        data['type'] = 'composite'
        data['rois'] = []
        data['count'] = len(roi.getRois())
        for i in range(len(roi.getRois())):
            data['rois'].append({})
            add_roi(data['rois'][i], roi.getRois()[i])
    elif roi_type == Roi.LINE:
        data['type'] = 'line'
        data['x1'] = roi.x1
        data['y1'] = roi.y1
        data['x2'] = roi.x2
        data['y2'] = roi.y2
    else:
        print('Unsupported roi type. Supported roi types include polygon, line, and composite.')
        return False
    return True


rm = RoiManager.getInstance()
if rm:
    count = rm.getCount()

    rois = rm.getRoisAsArray()
    data = {}
    data['classes'] = []
    data['rois'] = []
    data['count'] = count
    for i in range(count):
        data['classes'].append(rm.getName(i))
        data['rois'].append({})
        
        good = add_roi(data['rois'][i], rois[i])
    if good:
        title = str(IJ.getImage().title)
        title = title[0 : len(title) - 4]
        od = SaveDialog("Choose a file", title, '.json')
        if od:
            filename = od.getDirectory() + od.getFileName() 

            file = open(filename,'w')
            file.write(json.dumps(data))
            file.close()
                
            print("Saved to " + filename)
        else:
            print("Export cancelled")

else:
    print("No roi manager open")