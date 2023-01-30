classdef EAGMOEAD < ALGORITHM
% <multi> <real/integer/label/binary/permutation>
% External archive guided MOEA/D
% LGs --- 8 --- The number of learning generations

%------------------------------- Reference --------------------------------
% X. Cai, Y. Li, Z. Fan, and Q. Zhang, An external archive guided
% multiobjective evolutionary algorithm based on decomposition for
% combinatorial optimization, IEEE Transactions on Evolutionary
% Computation, 2015, 19(4): 508-523.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2023 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    methods
        function main(Algorithm,Problem)
            %% Parameter setting
            LGs = Algorithm.ParameterSet(8);

            %% Generate the weight vectors
            [W,Problem.N] = UniformPoint(Problem.N,Problem.M);
            T = ceil(Problem.N/10);

            %% Detect the neighbours of each solution
            B = pdist2(W,W);
            [~,B] = sort(B,2);
            B = B(:,1:T);

            %% Generate random population
            Population = Problem.Initialization();
            Archive    = Population;            % External archive
            s          = zeros(Problem.N,LGs);	% Number of successful solutions in last several generations

            %% Optimization
            while Algorithm.NotTerminated(Archive)
                [MatingPool,offspringLoc] = MatingSelection(B,s);
                Offspring  = OperatorGAhalf(Problem,Population(MatingPool));
                Population = UpdatePopulation(Population,Offspring,offspringLoc,W,B);
                [Archive,sucessful] = UpdateArchive(Archive,Offspring);
                % Update the number of successful solutions generated by
                % each subproblem in the last LGs generations
                if any(sucessful)
                    s(:,mod(ceil(Problem.FE/Problem.N),LGs)+1) = hist(offspringLoc(sucessful),1:Problem.N)';
                end
            end
        end
    end
end