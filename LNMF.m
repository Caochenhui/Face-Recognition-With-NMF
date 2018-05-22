function rc = LNMF( V, class_V, m_img, n_img, alpha, beta, Train_num, r, maxiter, T, class_T, Test_num, T_orignal)
%V-----------------ѵ�����ݼ���[m*n, Train_num*15]
%class_V-----------ѵ��������Ӧ�ķ���
%m_img-------------V��ͼ���ά��
%n_img-------------V��������
%r-----------------V����
%Train_num---------ѵ��������
%maxiter-----------����������
%T-----------------�������ݼ���[m*n, Test_num*15]
%class_T-----------����������Ӧ�ķ���
%Test_num----------ѵ��������

%% ѵ��
J = zeros(maxiter, 1);
V = V/max(V(:));
V(V == 0) = 2;                                                             %�滻0ֵ��������ۺ�����ɢ
V(V == 2) = min(min(V)) * 0.01;
T = T/max(T(:));
T(T == 0) = 2;                                                             %�滻0ֵ��������ۺ�����ɢ
T(T == 2) = min(min(T)) * 0.01;
W = abs(randn(m_img * n_img, r));                                          %�Ǹ���ʼ��
H = abs(randn(r, Train_num * 40));
for i = 1 : r                                                              %��W���и���ģΪ1��Լ��
    W(:, i) = W(:, i) / norm(W(:, i));
end                           
J(1) = sum(sum((V.*log(V./(W * H))) - V + W * H)) + ...
	 alpha * sum(sum(W' * W)) - beta * sum(diag(H * H'));                  %���ۺ���

for iter = 1: maxiter
    Wold = W;
    Hold = H;
    
    Vc = V./(Wold * Hold);
    H = sqrt(Hold.*(Wold' * Vc));                                          %����W��H
    W = Wold.*(Vc * H')./(repmat(sum(Wold, 2), [1, r]) + ...
        repmat(sum(H', 1), [m_img * n_img, 1]));

    for i = 1 : r                                                          %��W���и���ģΪ1��Լ��
        W(:, i) = W(:, i) / norm(W(:, i), 2);
    end
    
    J(iter) = sum(sum((V.*log(V./(W * H))) - V + W * H)) + ...
        alpha * sum(sum(W' * W)) - beta * sum(diag(H * H'));               %���´��ۺ���
end
%������ۺ���������
figure;
plot([1 : maxiter], J);
figure;
for i = 1 : r / 2
    subplot(8, 8, i);
    im = reshape(1- W(:, i), m_img, n_img); 
    imagesc(im);colormap('gray');  
end
figure;
for i = 1 : r / 2
    subplot(8, 8, i);
    im = reshape(1- W(:, i + r / 2), m_img, n_img); 
    imagesc(im);colormap('gray');  
end
%% ����
%���������������ݱ�ʾΪW��ʸ�����������
Ht = abs(randn(r, Test_num * 40));
Hold = Ht;
for iter = 1: maxiter    
    Ht = sqrt(Hold.*(W' * (T./(W * Hold))));                               %����H
end
VT = W * Ht;                                                               %�ع�ͼ
%����ع�ͼ
for i = 1 : Test_num * 40
    if mod(i, 20) == 1
        figure;
        m = 1;
    end
    subplot(4, 5, m);
    im = reshape(VT(:, i), m_img, n_img); 
    imagesc(im);colormap('gray');  
    m = m + 1;
end
%����ƥ����
right = 0;
dist = zeros(1, Train_num * 40);
class_recT = zeros(40 * Test_num, 1);
for i = 1 : Test_num * 40
    for j = 1 : Train_num * 40
        dist(j) = norm(Ht(:, i) - H(:, j))^2;                              %ѡȡϵ����ŷ�Ͼ����������Ϊʶ�����
    end
    [mindist index] = sort(dist);
    class_recT(i) = class_V(index(1));
end
for i = 1 : Test_num * 40                                                  %ͳ��ʶ����
    if class_recT(i) == class_T(i)
        right = right + 1;
    end
end
display(right / (Test_num * 40));
rc = right / (Test_num * 40);

