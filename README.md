# metaSegmentedXVAL
This repository contains code for the meta-segmented cross-validation described in the paper
Hammerla & Pl&ouml;tz, Let's (not) Stick Together: Pairwise Similarity Biases Cross-Validation in Activity Recognition, Ubicomp 2015.

## MATLAB
You can find matlab-code in the corresponding folder. *metacvpartition* provides a similar interface to matlab's *cvpartition*.

Running *help metacvpartition* will print out something like this:
```
Meta-segmented cross-validation.

C = metacvpartition(labels, nFolds, metaSegmentLength);

labels is a Nx1 matrix with (integer) labels. nFolds is the
number of folds in the cross-validation. metaSegmentLength
is the number of frames in each meta-segment.

C is an object with a similar interface to cvpartition.
    C.training(i)   Nx1     Indicator-matrix for
                            training-set i.
    C.test(i)       Nx1     Indicator-matrix for test-set
                            i.
Other fields:
    C.numtestSets
    C.foldDistribution
    C.classDistribution


Nils Hammerla 2015 <n.hammerla@gmail.com>
See LICENSE for license information.
```

Here is an example on using metacvpartition in matlab.
```matlab
% make some labels
labels = round((sin(linspace(0,5*pi,1000)')+1)*2)+1; % will be between 1 and 5
nFolds = 4;
metasegmentlength = 20; % 20 "frame" in each meta-segment
C = metacvpartition(labels, nFolds, metasegmentlength);
% C.training(i) contains training-indices of fold i
% C.test(i) contains test-indices of fold i
figure;
subplot(3,1,1); plot(labels); title('labels'); ylabel('class');
subplot(3,1,2);
hold on
plot(C.test(1)); % test-set 1
plot(C.test(3)); % test-set 2
title('Two test-sets');
% the folds should be stratified and have a similar class distribution
subplot(3,1,3);
bar(C.foldDistributions);
xlabel('fold'); title('class-distributions per fold');
```

This code should produce a figure like this:
![figure](/img/metacvpartition.png)

## Python and Lua
Are still in development but will be available shortly!
