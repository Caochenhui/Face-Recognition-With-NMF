function NMF_KL( V, m_img, n_img, Train_num, r, maxiter, T, Test_num)
%V-----------------ѵ�����ݼ���[m*n, Train_num*15]
%m_img-------------V��ͼ���ά��
%n_img-------------V��������
%r-----------------V����
%Train_num---------ѵ��������
%maxiter-----------����������
%T-----------------�������ݼ���[m*n, Test_num*15]
%Test_num----------ѵ��������

%% ѵ��
J = zeros(maxiter, 1);
V = V/max(V(:));                                                           %��һ��
V(V == 0) = 2;                                                             %�滻0ֵ��������ۺ�����ɢ
V(V == 2) = min(min(V)) * 0.01;
W = abs(randn(m_img * n_img, r));                                          %�Ǹ���ʼ��
H = abs(randn(r,Train_num * 15));
J(1) = sum(sum((V.* log(V./(W * H))) - V + W * H));                        %���ۺ���ΪKLɢ��

for iter = 1: maxiter
    Wold = W;
    Hold = H;
    W = Wold.*((V./(Wold * Hold + 1e-9)) * Hold')./(ones(m_img * n_img,1) * sum(Hold'));%����W��H
    H = Hold.*(W' * (V./(W * Hold + 1e-9)))./(sum(W)' * ones(1, Train_num * 15));

    norms = sqrt(sum(H'.^2));                                              %��һ��
    H = H./(norms'*ones(1,Train_num * 15));
    W = W.*(ones(m_img * n_img,1)*norms);
    
    J(iter) = sum(sum((V.* log(V./(W * H))) - V + W * H));                 %���´��ۺ���
end
%������ۺ���������
figure;
plot([1 : maxiter], J);
figure;
for i = 1 : r
    subplot(5, 8, i);
    im = reshape(W(:, i), m_img, n_img); 
    imagesc(im);colormap('gray');  
end

%% ����
%���������������ݱ�ʾΪW��ʸ�����������
Ht = abs(randn(r, Test_num * 15));
for iter = 1: maxiter
    Hold = Ht;
    Ht = Hold.* ((W') * T)./((W') * W * Hold + 1e-9);                      %����W��H

    norms = sqrt(sum(Ht'.^2));                                             %��һ��
    Ht = Ht./(norms'*ones(1,Test_num * 15));
end
VT = W * Ht;
%����ع�ͼ
for i = 1 : Test_num * 15
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
VT = VT/max(VT(:));
T = T/max(T(:));
e = mean(sum(abs(T - VT))./sum(abs(T)));
display(1 - e);
