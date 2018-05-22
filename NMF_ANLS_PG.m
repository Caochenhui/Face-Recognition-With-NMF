function NMF_ANLS_PG( V, m_img, n_img, Train_num, r, maxiter, T, Test_num)
%V-----------------ѵ�����ݼ���[m*n, Train_num*15]
%m_img-------------V��ͼ���ά��
%n_img-------------V��������
%r-----------------V����
%Train_num---------ѵ��������
%maxiter-----------����������
%T-----------------�������ݼ���[m*n, Test_num*15]
%Test_num----------ѵ��������

%% ѵ��
W = abs(randn(m_img * n_img, r));                                          %�Ǹ���ʼ��
H = abs(randn(r,Train_num * 15));
gradW = W * (H * H') - V * H';                                             %�ֱ����W�ݶȺ�H�ݶ�
gradH = (W' * W) * H - W' * V;    
tol_W = 0.001 * norm([gradW; gradH'],'fro');
tol_H = tol_W;

for iter = 1: maxiter
    [W, gradW, iterW] = nlssubprob(V', H', W', tol_W, 1000); 
    W = W'; 
    gradW = gradW';
    if iterW == 1
        tol_W = 0.1 * tol_W;
    end
    
    [H, gradH, iterH] = nlssubprob(V, W, H, tol_H, 1000);
    if iterH == 1
        tol_H = 0.1 * tol_H;
    end
end
%������ۺ���������
% figure;
% plot([1 : maxiter], J);
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
    Ht = Hold.* ((W') * T)./((W') * W * Hold + 1e-9);                      %����H

    norms = sqrt(sum(Ht'.^2));                                             %��һ��
    Ht = Ht./(norms'*ones(1,Test_num * 15));
end
VT = W * Ht;                                                               %�ع�ͼ
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


