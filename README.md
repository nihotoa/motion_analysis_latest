## Overview
This repository provides comprehensive processing related to 3D motion analysis. <br>
The following are some specific processing examples.
  - Extracting video for motion analysis
  - Time synchronization with EMG recorded together
  - Illustration of the movement trajectory
  - Calculation of joint angles
  - useDataFold/<monkeyname>/movie/taskMovie/<date>

***

## How to Analyze

  - <span style="font-size: 18px;">**Preliminary Preparations**</span>

    - Please create the following directory and store the task videos you have taken there
      > motion_analysis_latest/useDataFold/[monkeyname]/movie/taskMovie/[date]/
      
      Also, Please name each video taken from the camera as follows
      > camera1.mp4

      The number is used to identify the camera. It is up to you to decide which camera corresponds to which number, but please be careful not to change the camera number correspondence from day to day.

      (e.g.)<br>
      if monkey name is 'Pochi', recording date is '2025/01/01', and the camera number is 3, Please save the videos taken from this camera as follows:
      > motion_analysis_latest/useDataFold/Pochi/movie/taskMovie/20250101/camera3.mp4

      <br>

    - Understand the directory structure of this repository

      The most important thing to understand this repository is to understand the hierarchical structure of the folders.<br>
      This repository mainly consists of **4** main directories
        - code <br> => functions that make up executeFunctions.
        - executeFunctions <br> => functions that the user needs to execute
        - saveFold <br> => Directory for storing preprocessing and analysis results
        - useDataFold <br> => Directory that stores data used for preprocessing and analysis

      For more detailed structure, please refer to the following tree.
      ```
      motion_analysis_latest
        ├── code
        │   ├── commonFunc
        │   │   └── ...
        │   ├── trimMovieFunc
        │   │   └── ...
        │   └── ...
        ├── executeFunctions
        │   ├── extractTrialVideos.m
        │   └── ...
        ├── saveFold
        │   ├── monkey1
        │   │   ├── movie
        │   │   │   └── ...
        │   │   └── data
        │   │       └── ....
        │   ├── monkey2
        │   │   ├── movie
        │   │   │   └── ...
        │   │   └── data
        │   │       └── ....
        │   └── ...
        └── useDataFold
            ├── monkey1
            │   ├── movie
            │   │   └── ...
            │   └── data
            │       └── ....
            ├── monkey2
            │   ├── movie
            │   │   └── ...
            │   └── data
            │       └── ....
            └── ...
      ```
      <!-- # code
        ## commonFunc
          ### ...
        ## trimMovieFunc
          ### ...
        ## ...
      # executeFunctions
        ## extractTrialVideos.m
        ## ...
      # saveFold
        ## monkey1
          ### movie
            #### ...
          ### data
            #### ....
        ## monkey2
          ### movie
            #### ...
          ### data
            #### ....
        ## ...
      # useDataFold
        ## monkey1
          ### movie
            #### ...
          ### data
            #### ....
        ## monkey2
          ### movie
            #### ...
          ### data
            #### ....
        ## ... -->

    - Please add this repository to PATH in MATLAB

      <!-- insert image -->
      <img src="" alt="addPathExplanation" width="100%" style="display: block; margin-left: auto; margin-right: auto; padding: 20px">

  - <span style="font-size: 18px;">**Sequence of Analysis**</span>

    The sequence of motion analysis is shown in the figure below.(All functions to be executed are directly under executeFunctions folder.)<br>

    <!-- insert image -->
    <img src="" alt="workflowFigure" width="80%" style="display: block; margin-left: auto; margin-right: auto; padding: 20px">

    For details on the usage and the role of each function, please refer to the description at the beginning of each function.

***

## Remarks
  The following information is written at the beginning of every executed function. Please refer to them and proceed with the analysis.
  - **Your operation**<br>
    This section contains instructions for executing the code

  - **Role of this code**<br>
    The role of code is briefly described in this section

  - **Saved data location**<br>
    This section contains details of data to be saved and where these data are saved

  - **Procedure**<br>
    This section describes which code should be executed before and after this code.

***
## Other information
  - This project requires the processing of <a href="https://github.com/DeepLabCut/DeepLabCut">DeepLabCut</a> and <a href="https://github.com/lambdaloop/anipose">Anipose</a>. Therefore, you will need to prepare these environments.
  - Details of the experiment and analysis outline are distributed separately. If you would like to get these information, <strong>please contact at the email address at the end of this README.</strong>
***

## Contact

  If you have any questions, please feel free to contact me at nao-ota@ncnp.go.jp
