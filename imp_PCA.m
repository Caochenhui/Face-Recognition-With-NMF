function rc = imp_PCA(m_img, n_img, V, class_V, Train_num, T, class_T, Test_num, T_orignal)
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

eig_num = 128;                                                             %��ȡ����ά��
k = 64;                                                                    %ѡ�õ�k��������
c = 8;                                                                     %�����c��α����
%% ��ȡ���ͼ�񣬼���Э�������ȡ����ֵ
Vmean = V;
Tmean = T;
%���
mean_V = mean(V,2);
mean_T = mean(T,2);
for i = 1:Train_num * 40
    Vmean(:,i) = V(:,i) - mean_V;
end
Vmean = double(Vmean);                                                     %ȥ���Ļ�
for i = 1:Test_num * 40
    Tmean(:,i) = T(:,i) - mean_T;   
end
Tmean = double(Tmean);
%Э�����������
C = (1/Train_num) * (Vmean' * Vmean);
[v, D] = eigs(C, eig_num);                                                 %����eig_num����������ֵ��Ӧ����������
v = C' * v;                                                                %C ����������
for i = 1 : eig_num
    v(:, i) = v(:, i)/norm(v(:, i));
end
Wc = zeros(Train_num * 40, c);
rN = rand(1, eig_num - k);
for i = 1 : c                                                              %����c��ʣ�������������������
    Wc(:, i) = v(:, k + 1 : eig_num) * rN';                   
    Wc(:, i) = Wc(:, i)/norm(Wc(:, i));                                    %��һ��ģ
end
% Wc_orth = Wc * (Wc' * Wc)^-0.5;
Vec = zeros(Train_num * 40, k + c);
Vec(:, 1 : k) = v(:, 1 : k);
Vec(:, k + 1 : k + c) = Wc(:, 1 : c);
%% ѵ��
%��������
eigenface = Vmean * Vec;
%���������
figure;
for i = 1:k + c  
    im = eigenface(:,i);   
    im = reshape(im, m_img, n_img);
    subplot(8,16,i);  
    im = imagesc(im);colormap('gray');  
end
suptitle('ͼ1-PCA������');
%�����ѵ��ͼͶӰ���������ռ�
Vproject = Vmean' * eigenface;

%% ����
%������ͼͶӰ�������ռ�
Tproject = Tmean' * eigenface;
A = eigenface \ T;                                                         %���Լ�����������ͶӰϵ������
T_hat = eigenface * A;                                                     %�ع���������
AV = eigenface \ V;                                                        %ѵ��������������ͶӰϵ������
V_hat = eigenface * AV;                                                    %�ع�ѵ������
%����ع�ͼ
for i = 1 : Test_num * 40
    if mod(i, 20) == 1
        figure;
        m = 1;
    end
    subplot(4, 5, m);
    im = reshape(T_hat(:, i), m_img, n_img); 
    imagesc(im);colormap('gray');  
    m = m + 1;
end
%�����ع�׼ȷ��
right = 0;
dist = zeros(1, Train_num * 40);
class_recT = zeros(40 * Test_num, 1);
for i = 1 : Test_num * 40
    for j = 1 : Train_num * 40
        dist(j) = norm(A(:, i) - AV(:, j))^2;                              %ѡȡϵ����ŷ�Ͼ����������Ϊʶ�����
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