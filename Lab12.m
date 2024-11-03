clc
clear
close all

%cost efficiency is interesting here

load('inputs-outputs-prices.mat', 'data', 'prices');

[n,m] = size(data);
inputs = 2;
outputs = 2;

%% Fare model

%lecture 12, page 12
%c - costs
%x - input numbers

%2 sets of variables - x and lamdas, 12 lamdas, 2 types of people = 14 variables
%variables -> [x lamdas]
%min 500x1 + 100x2 + 0*lamda1 + ... + 0*lamda12
%model.obj = [Prices(i, :) zeros(1,12)];

X = data(:, 1:inputs);
Y = data(:, inputs+1:m);
observed_cost = sum(X.*prices, 2);
cost_efficiency_F = nan(n, 1);

for i = 1:n
	model_Fare.obj = [prices(i, :) zeros(1, n)];
	model_Fare.modelsense = 'min';
	
	%first contrain
    	%lamda*x<=x1
    	%-1 0 20lamda1 19lamda2.....<=0
    	%0 -1 151lamda1 131lamda2......<=0
	a1 = [-eye(inputs) X'];

	%lamda*y >= y0
	% 0 0 100lamda1 150lamda2.... >=100
	% 0 0 90lamda1 50lamda2......>=90
	a2 = [zeros(outputs, inputs) Y'];

	model_Fare.A = sparse([a1; a2]);

	model_Fare.rhs = [zeros(inputs, 1); Y(i, :)'];
	model_Fare.sense = [repmat('<', 1, inputs) repmat('>', 1, outputs)];

	params.outputflag = 0;
	result = gurobi(model_Fare, params);
	cost_efficiency_F(i, 1) = result.objval/observed_cost(i, 1);
end 

%% Tone model

X = data(:, 1:inputs).*prices; %difference
Y = data(:, inputs+1:m);
observed_cost = sum(X.*prices, 2);
cost_efficiency_T = nan(n, 1);

for i = 1:n
	model_Tone.obj = [ones(1, inputs) zeros(1, n)]; %only difference
	model_Tone.modelsense = 'min';
	
	a1 = [-eye(inputs) X'];
	a2 = [zeros(outputs, inputs) Y'];

	model_Tone.A = sparse([a1; a2]);

	model_Tone.rhs = [zeros(inputs, 1); Y(i, :)'];
	model_Tone.sense = [repmat('<', 1, inputs) repmat('>', 1, outputs)];

	params.outputflag = 0;
	result = gurobi(model_Tone, params);
	cost_efficiency_T(i, 1) = result.objval/observed_cost(i, 1);
end 


%% Comparision

%In model 1 Fare prices are fixed.
%In Tone model prices can be optimized. Unit can be "price makers" and can adjust them.
%Mixed situations are possible, some prices are fixed, but other not.




