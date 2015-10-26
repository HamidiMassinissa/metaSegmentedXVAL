classdef metacvpartition
    properties
        N                   = [];
        NumTestSets         = [];
        TrainSize           = [];
        TestSize            = [];
        indices             = [];
        foldDistributions   = [];
        classDistribution   = [];
    end

    methods
        function cv = metacvpartition(labels, nFolds, metaSegmentLength)
            %
            %   Meta-segmented cross-validation.
            %
            %   C = metacvpartition(labels, nFolds, metaSegmentLength);
            %
            %   labels is a Nx1 matrix with (integer) labels. nFolds is the
            %   number of folds in the cross-validation. metaSegmentLength
            %   is the number of frames in each meta-segment.
            %
            %   C is an object with a similar interface to cvpartition.
            %       C.training(i)   Nx1     Indicator-matrix for
            %                               training-set i.
            %       C.test(i)       Nx1     Indicator-matrix for test-set
            %                               i.
            %   Other fields:
            %       C.numtestSets
            %       C.foldDistribution
            %       C.classDistribution
            %
            %
            %   Nils Hammerla 2015 <n.hammerla@gmail.com>
            %   See LICENSE for license information.
            %

            % initialize
            cv.N = length(labels);
            cv.NumTestSets = nFolds;

            % number of meta-segments
            nP = ceil(cv.N / metaSegmentLength);
            cv.indices = zeros(cv.N,1);

            % get classes
            c = unique(labels);
            % transform to integer labels
            L = labels;
            for i=1:length(c),
                L(labels == c(i)) = i;
            end

            % get overall distribution of labels
            cv.classDistribution = accumarray(L,1)';

            % initialize meta-segment class distribution matrix
            cDist = zeros(nP,length(c));
            cv.foldDistributions = zeros(nFolds, length(c));

            % estimate class distributions for each meta-segment
            for i=1:nP,
                % get meta-segment label-distribution
                if i*metaSegmentLength <= cv.N,
                    l = L((i-1)*metaSegmentLength+1:i*metaSegmentLength);
                else
                    l = L((i-1)*metaSegmentLength+1:end);
                end

                % get labels unique to this meta-segment
                d = unique(l);

                % save in matrix
                dl = accumarray(l,1);
                dl(dl>0) = dl(dl>0) + rand(sum(dl>0),1)*0.1;
                % assign non-zero elements
                cDist(i,d) = dl(dl>0);
                % add some noise for randomness of xval
                cDist(i,:) = cDist(i,:);
            end

            % Here comes the trick: sort lexicographically
            [~,I] = sortrows(cDist);

            % "I" now contains sorted list of distributions (ascending)
            % Now: assign folds
            ind = 1+mod(1:length(I),nFolds); % 1 2 3 4 5 1 2 3 4 5 ...
            ind(I) = ind;

            % save fold-wise distributions for reference
            for i=1:nFolds,
                d = sum(cDist(ind == i,:));
                cv.foldDistributions(i,:) = d ./ sum(d);
            end

            % assign fold to each sample
            for i=1:nP,
                cv.indices((i-1)*metaSegmentLength+1:i*metaSegmentLength) = ind(i);
            end

            % make sure the indices it's the right size
            cv.indices = cv.indices(1:cv.N);

            cv.TestSize = accumarray(cv.indices,1)';
            cv.TrainSize = size(cv.indices,1) - cv.TestSize;
        end

        function trainIndices = training(cv, fold)
            % return binary training mask from fold "fold"
            trainIndices = cv.indices ~= fold;
        end

        function testIndices = test(cv, fold)
            % return binary testing mask from fold "fold"
            testIndices = cv.indices == fold;
        end
    end

end
