function rc = NMF_mse( V, class_V, m_img, n_img, Train_num, r, maxiter, T, class_T, Test_num, T_orignal)
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
V = V / max(V(:));
W = abs(randn(m_img * n_img, r));                                          %�Ǹ���ʼ��
H = abs(randn(r, Train_num * 40));
J(1) = 0.5 * sum(sum((V - W * H).^2));                                     %���ۺ���Ϊŷ�Ͼ���

for iter = 1: maxiter
    Wold = W;
    Hold = H;
    H = Hold.* ((Wold') * V)./((Wold') * Wold * Hold + 1e-9);              %����W��H
    W = Wold.* (V * (H'))./(Wold * H * (H') + 1e-9);

    norms = sqrt(sum(H'.^2));                                              %��һ��
    H = H./(norms'*ones(1, Train_num * 40));
    W = W.*(ones(m_img * n_img, 1)*norms);
    
    J(iter) = 0.5 * sum(sum(( V - W * H).^2));                             %���´��ۺ���
end
%������ۺ���������
figure;
plot([1 : maxiter], J);
% figure;
% for i = 1 : r
%     subplot(8, 16, i);
%     im = reshape(W(:, i), m_img, n_img); 
%     imagesc(im);colormap('gray');  
% end

%% ����
%���������������ݱ�ʾΪW��ʸ�����������
Ht = abs(randn(r, Test_num * 40));
for iter = 1: maxiter
    Hold = Ht;
    Ht = Hold.* ((W') * T)./((W') * W * Hold + 1e-9);                      %����H

    norms = sqrt(sum(Ht'.^2));                                             %��һ��
    Ht = Ht./(norms'*ones(1,Test_num * 40));
end
rec_V = W * H;
rec_T = W * Ht;                                                            %�ع�ͼ
%����ع�ͼ
for i = 1 : Test_num * 40
    if mod(i, 20) == 1
        figure;
        m = 1;
    end
    subplot(4, 5, m);
    im = reshape(rec_T(:, i), m_img, n_img); 
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

