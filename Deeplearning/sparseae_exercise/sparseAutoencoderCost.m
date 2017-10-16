function [cost,grad] = sparseAutoencoderCost(theta, visibleSize, hiddenSize, ...
                                             lambda, sparsityParam, beta, data)

% visibleSize: the number of input units (probably 64) 
% hiddenSize: the number of hidden units (probably 25) 
% lambda: weight decay parameter
% sparsityParam: The desired average activation for the hidden units (denoted in the lecture
%                           notes by the greek alphabet rho, which looks like a lower-case "p").
% beta: weight of sparsity penalty term
% data: Our 64x10000 matrix containing the training data.  So, data(:,i) is the i-th training example. 
  
% The input theta is a vector (because minFunc expects the parameters to be a vector). 
% We first convert theta to the (W1, W2, b1, b2) matrix/vector format, so that this 
% follows the notation convention of the lecture notes. 

W1 = reshape(theta(1:hiddenSize*visibleSize), hiddenSize, visibleSize);
W2 = reshape(theta(hiddenSize*visibleSize+1:2*hiddenSize*visibleSize), visibleSize, hiddenSize);
b1 = theta(2*hiddenSize*visibleSize+1:2*hiddenSize*visibleSize+hiddenSize);
b2 = theta(2*hiddenSize*visibleSize+hiddenSize+1:end);

% Cost and gradient variables (your code needs to compute these values). 
% Here, we initialize them to zeros. 
cost = 0;
W1grad = zeros(size(W1)); 
W2grad = zeros(size(W2));
b1grad = zeros(size(b1)); 
b2grad = zeros(size(b2));

%% ---------- YOUR CODE HERE --------------------------------------
%  Instructions: Compute the cost/optimization objective J_sparse(W,b) for the Sparse Autoencoder,
%                and the corresponding gradients W1grad, W2grad, b1grad, b2grad.
%
% W1grad, W2grad, b1grad and b2grad should be computed using backpropagation.
% Note that W1grad has the same dimensions as W1, b1grad has the same dimensions
% as b1, etc.  Your code should set W1grad to be the partial derivative of J_sparse(W,b) with
% respect to W1.  I.e., W1grad(i,j) should be the partial derivative of J_sparse(W,b) 
% with respect to the input parameter W1(i,j).  Thus, W1grad should be equal to the term 
% [(1/m) \Delta W^{(1)} + \lambda W^{(1)}] in the last block of pseudo-code in Section 2.2 
% of the lecture notes (and similarly for W2grad, b1grad, b2grad).
% 
% Stated differently, if we were using batch gradient descent to optimize the parameters,
% the gradient descent update to W1 would be W1 := W1 - alpha * W1grad, and similarly for W2, b1, b2. 
% 
[n,m]=size(data)%data是10000个图片截取，m为图片个数
%前向传播
Z2=W1*data+repmat(b1,1,m);%b1向量拓展程m列矩阵（对每一个图片都得加b1，所以要拓展）
A2=sigmoid(Z2);
Z3=W2*A2+repmat(b2,1,m);
A3=sigmoid(Z3);
%构造loss function
error=A3-data;
cost=0.5/m*sum((error(:).^2));%所有样例的代价函数之和-均方差项，lose function 的第一项

cost=cost+lambda/2*(sum(W1(:).^2)+sum(W2(:).^2));%lose function 第二项，规则化项，把所有的权重相加

rho=mean(A2,2); %2代表求每一行的平均值，就是对每一个图片都求一个rho
rho0=sparsityParam;%传参传入的稀疏性参数

KLsum=sum(rho0.*(rho0./rho)+(1-rho0)*log((1-rho0)./(1-rho)));%lose function 的第三项，相对熵的和
cost=cost+beta*KLsum;
%计算输出层delta
delta3=-1*(data-A3).*A3.*(1-A3);
delta2=(W2'*delta3+beta*repmat( (-rho0./rho+(1-rho0)./(1-rho)),1,m).*A2.*(1-A2));

%只考虑error term 
W2grad=delta3*A2'/m;
b2grad=mean(delta3,2);
W1grad=delta2*data'/m;
b1grad=mean(delta2,2);

%添加weight decay term
W2grad=W2grad+lambda*W2;
W1grad=W1grad+lambda*W1;


















%-------------------------------------------------------------------
% After computing the cost and gradient, we will convert the gradients back
% to a vector format (suitable for minFunc).  Specifically, we will unroll
% your gradient matrices into a vector.

grad = [W1grad(:) ; W2grad(:) ; b1grad(:) ; b2grad(:)];

end

%-------------------------------------------------------------------
% Here's an implementation of the sigmoid function, which you may find useful
% in your computation of the costs and the gradients.  This inputs a (row or
% column) vector (say (z1, z2, z3)) and returns (f(z1), f(z2), f(z3)). 

function sigm = sigmoid(x)
  
    sigm = 1 ./ (1 + exp(-x));
end

