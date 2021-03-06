### IMPORTS

import sys
sys.path.append('PyGazeAnalyser-master\\pygazeanalyser')

#pygaze imports
#from pygaze import *
from edfreader import *
from gazeplotter import *

#other python libs import
import numpy as np
import matplotlib.pyplot as plt
import time

#csv import 
import csv
import cv2



def read_data(partic_id,game_nr,phase='stimulus'):

    """
    Reads data from the asc file for different phases namely fixation, stimulus, reward

    @Input: 
	    Partic_id : Pariticipant id
	    game_nr   : Game no
	    Phase     : 'fixation', 'stimulus' or 'reward'
    

    Returns:
	   data : dict containing all the data (refer to pygazeanalyser github)	
    """
    fname = 'Participant Data/'+str(partic_id)+ '/' + str(partic_id) + \
             str('_') + str(game_nr) + str('.asc') #path of the ASC file

    if phase =='stimulus':
        start_message = 'SYNCTIME'
        stop_message = 'CC'
    elif phase =='fixation':
        start_message = 'TRIALID'
        stop_message = 'SYNCTIME'
    elif phase =='reward':
        start_message = 'CC'
        stop_message = 'TRIALEND'
    data = read_edf(fname,start=start_message,stop=stop_message) #start and stop indicators can be found in the ASC file
    return data

def read_data2(partic_id, phase='stimulus'):

    """
    Reads data from the asc file for different phases namely fixation, stimulus, reward

    @Input: 
	    Partic_id : Pariticipant id
	    Phase     : 'fixation', 'stimulus' or 'reward'
    

    Returns:
	   data : dict containing all the data from all games 	
    """
    if phase =='stimulus':
        start_message = 'SYNCTIME'
        stop_message = 'CC'
    elif phase =='fixation':
        start_message = 'TRIALID'
        stop_message = 'SYNCTIME'
    elif phase =='reward':
        start_message = 'CC'
        stop_message = 'TRIALEND'
        
    data = []
    for game_nr in (1,16):
        fname = 'Participant Data/'+str(partic_id)+ '/' + str(partic_id) + \
                 str('_') + str(game_nr) + str('.asc') #path of the ASC file
        data = data + read_edf(fname,start=start_message,stop=stop_message) #start and stop indicators can be found in the ASC file
    return data

def load_dataset_properties(fname):
    
    """
    Loads stimulus properties from a given file

    @Input: 	
	fname: csv file containing the stimulus data

    Returns:
	data_set : list containing stimulus data sorted by rows

    """
    #fname = 'dataset_0423.csv'

    #read and store into data_set
    data_set = []
    with open(fname, newline='') as csvfile:
        csvreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
        for row in csvreader:
            row = row[0].split(',') #split by comma separated 
            data_set.append(row)
    return data_set

def return_property_value(data_set,subject_id, game_nr,trial_nr,property_label):

    """
    Returns the stimulus property based on data_set and subject id
	
    @Input: 
	data_set : Data loaded from the load_dataset_properties()
	subject_id: Participant number (integer only; eg 36)
	game_nr, trial_nr : Game number, trial number
	property_label: ['subject_nr', 'subject_id', 'game_nr', 'trial_nr', 'perc_noise', 
			'perc_noise_sample', 'orientation', 'orientation_sample', 'orientation_0', 'orientation_0_sample', 
			'orientation_positive_unfair', 'orientation_positive_fair', 'reference_line'])
    Returns:
	property_value : float value of the corresponding property_label from the data_set
	
    """
    #subject_id = 36
    #game_nr = 1
    #trial_nr = 5
    ### Convert to numpy array
    data_set_arr = np.array(data_set[1:]).astype(float)
    #reshape
    data_set_arr.reshape(35,16,18,-1)
    data_set_arr.shape
    #retrieve perc_noise_sample
    #property_label = 'perc_noise_sampe'
    index_property = data_set[0].index(property_label)
    property_value = data_set_arr[(subject_id-2)*(game_nr-1)*(trial_nr-1),index_property]
    return property_value


def draw_heatmap_saccade(data,partic_id,game_nr,trial_nr):

	"""
	Draws saccadic path ON TOP OF heatmaps and saves it in the current folder for a given data 

	@Input:
		data: dataset loaded as per read_data()
	 	trial_nr: trial number

	Returns:
		None
	
	(Saves the heatmap in the current folder)
	"""
	#trial_nr = 12
	#saccades and fixations
	saccades = np.array(data[trial_nr]['events']['Esac'])
	fixations = np.array(data[trial_nr]['events']['Efix'])
	dispsize= (1919,1079) # (px,px) size of screen 

	# draw saccadic scanpath and save fig
	#saves as id+game_nr+trial_nr+current date time

	savefilename = 'output_images/' + str(partic_id) + '_game_'+str(game_nr)+'_' \
               + str(trial_nr) + '_'+ time.strftime("%Y%m%d-%H%M%S")
	fig = draw_scanpath(fixations, saccades, dispsize, imagefile=None, alpha=0.5, savefilename=savefilename)

	#draw heatmap on top of it
	img_file = savefilename + '.png'
	fig_heatmap = draw_heatmap(fixations, dispsize, imagefile=img_file)
	img_heatmap_file = savefilename + '_heatmap'
	fig_heatmap.savefig(img_heatmap_file)

def draw_heatmap_trial(data,partic_id,game_nr,trial_nr):

	"""
	Draws heatmaps and saves it in the current folder for a given data 

	@Input:
		data: dataset loaded as per read_data()
	 	trial_nr: trial number

	Returns:
		None
	
	(Saves the heatmap in the current folder)
	"""
	#trial_nr = 12
	#saccades and fixations
	fixations = np.array(data[trial_nr]['events']['Efix'])
	dispsize= (1919,1079) # (px,px) size of screen 

	# draw saccadic scanpath and save fig
	#saves as id+game_nr+trial_nr+current date time

	savefilename = 'output_images/' + str(partic_id) + '_game_'+str(game_nr)+'_' \
               + str(trial_nr) + '_'+ time.strftime("%Y%m%d-%H%M%S")

	#draw heatmap 
	fig_heatmap = draw_heatmap(fixations, dispsize, imagefile=None)
	img_heatmap_file = savefilename + '_heatmap'
	fig_heatmap.savefig(img_heatmap_file)
	


def return_centroid_heatmap(image_file):
    """
    Finds circular contours in the image and returns the center and radius
    
    @Input: image_load: Input image of the heatmap
    
    Returns: 
	center_list (x,y) : List of centers (if there are multiple circles detected)
	radius (r) : List of radii 
	image_out : Image with (circular) contours marked
    """

    #load image using open cv
    image_load = cv2.imread(image_file,0)
    ## find number of blobs 

    #threshold
    _,thresh_image = cv2.threshold(image_load,10,255,cv2.THRESH_BINARY)#+cv2.THRESH_OTSU)cv2.threshold(img_gray, thresh, 150, 255, THRESH_BINARY);
    contours, hierarchy = cv2.findContours(thresh_image,cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)


    center_list = [] #relevant contours 
    radius_list = [] #relevant radii 
    for cnt in contours:
        #check for circle enclosing contour
        (x,y),radius = cv2.minEnclosingCircle(cnt)
        center = (int(x),int(y))
        radius = int(np.ceil((radius)))

        if radius <100:
            #draw circular contours
            cv2.circle(image_load,center,radius,(255,255,0),2)
            center_list.append([x,y])
            radius_list.append(radius)
            #cv2.drawContours(image_load,cnt,contourIdx=-1, color=(255, 255, 0), thickness=2,\
                         #lineType=cv2.LINE_AA)   
        
    return np.array(center_list),radius_list,image_load


def return_cross_pos(partic_id,game_nr,trial_nr):
    """
    Returns the averaged cross_hair position as calculated from the
    fixation time
    
    
    @Input:
	    data : data during fixation time


    Returns:
	   x_mean, y_mean : (averaged out)x,y coordinates of the crosshair         
    """
    
    fname = 'Participant Data/'+str(partic_id)+ '/' + str(partic_id) + \
         str('_') + str(game_nr) + str('.asc') #path of the ASC file
    data = read_edf(fname,start='TRIALID',stop='SYNCTIME') #fixation time
    Efix = np.array(data[trial_nr]['events']['Efix'])
    
    #check if Efix is 2D 
    if len(Efix.shape)>1:
        x_mean,y_mean = np.mean(Efix[:,-2]),np.mean(Efix[:,-1])
    
    elif Efix.size==0:
        x_mean,y_mean = 0, 0 # 0,0 for no Efix value
    
    else:
        x_mean,y_mean = Efix[-2:]

    return x_mean, y_mean


