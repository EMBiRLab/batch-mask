import json
import argparse
import numpy as np
import cv2
import glob
import os
import easygui

def readtps(input):
    """
    Function to read a .TPS file
    Args:
        input (str): path to the .TPS file
    Returns:
        lm (str list): info extracted from 'LM=' field
        im (str list): info extracted from 'IMAGE=' field
        id (str list): info extracted from 'ID=' filed
        coords: returns a 3D numpy array if all the individuals have same
                number of landmarks, otherwise returns a list containing 2d
                matrices of landmarks
    """

    # open the file
    tps_file = open(input, 'r')  # 'r' = read
    tps = tps_file.read().splitlines()  # read as lines and split by new lines
    tps_file.close()

    # initiate lists to take fields of "LM=","IMAGE=", "ID=" and the coords
    lm, im, ID, coords_array = [], [], [], []

    # looping thru the lines
    for i, ln in enumerate(tps):

        # Each individual starts with "LM="
        if ln.startswith("LM"):
            # number of landmarks of this ind
            lm_num = int(ln.split('=')[1])
            # fill the info to the list for all inds
            lm.append(lm_num)
            # initiate a list to take 2d coordinates
            coords_mat = []

            # fill the coords list by reading next lm_num of lines
            for j in range(i + 1, i + 1 + lm_num):
                coords_mat.append(tps[j].split(' '))  # split lines into values

            # change the list into a numpy matrix storing float vals
            coords_mat = np.array(coords_mat, dtype=float)
            # fill the ind 2d matrix into the 3D coords array of all inds
            coords_array.append(coords_mat)
            # coords_array.append(coords_mat)

        # Get info of IMAGE= and ID= fields
        if ln.startswith("IMAGE"):
            im.append(ln.split('=')[1])

        if ln.startswith("ID"):
            ID.append(ln.split('=')[1])

    # check if all inds contains same number of landmarks
    all_lm_same = all(x == lm[0] for x in lm)
    # if all same change the list into a 3d numpy array
    if all_lm_same:
        coords_array = np.dstack(coords_array)

    # return results in dictionary form
    return {'lm': lm, 'im': im, 'id': ID, 'coords': coords_array}

if __name__ == '__main__':

    tps_file = easygui.fileopenbox(title = "Open tps file")
    
    tps_data = readtps(tps_file)
    path = os.path.dirname(tps_file)
    print(tps_data)
    
    for i in range(len(tps_data['im'])):
      filename = tps_data['im'][i].split('.')[0] + '.json'
      with open(os.path.join(path, filename), 'w') as file:
        img = cv2.imread(os.path.join(path, tps_data['im'][i]))
        print(os.path.join(path, tps_data['im'][i]))
        height = img.shape[0]
        data = {}
        data['count'] = 1
        data['classes'] = ['snake']
        data['rois'] = [{}]
        data['rois'][0]['type'] = 'polygon'
        data['rois'][0]['x'] = []
        data['rois'][0]['y'] = []
        data['rois'][0]['count'] = tps_data['lm'][i]
        for j in range(tps_data['lm'][i]):
          data['rois'][0]['x'].append(int(tps_data['coords'][j][0][i]))
          data['rois'][0]['y'].append(int(height - tps_data['coords'][j][1][i]))

        print(data)
        json.dump(data, file)
      