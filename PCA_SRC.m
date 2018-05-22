function rc = PCA_SRC( V, class_V, Train_num, T, class_T, Test_num)
%V-----------------ѵ�����ݼ���[m*n, Train_num*15]
%m_img-------------V��ͼ���ά��
%n_img-------------V��������
%r-----------------V����
%Train_num---------ѵ��������
%maxiter-----------����������
%T-----------------�������ݼ���[m*n, Test_num*15]
%Test_num----------ѵ��������

eig_num = 64;                                                              %��ȡ����ά��
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
C = (1/Train_num) * (Vmean * Vmean');
[Vec, D] = eigs(C, eig_num);                                               %����eig_num����������ֵ��Ӧ����������
Vec = C' * Vec;                                                            %C ����������
for i = 1 : eig_num
    Vec(:, i) = Vec(:, i)/norm(Vec(:, i));
end

%% ѵ��
%��������
eigenface = (Vmean' * Vec)';                                               %ѵ�����������ռ��ͶӰ����������
eigenfaceT = (Tmean' * Vec)';                                              %���Լ��������ռ��ͶӰ
eigenface = normc(eigenface);                                              %��һ��ģ
eigenfaceT = normc(eigenfaceT);
e = 0.0005 * sqrt(eig_num) * sqrt(1 + 2 * sqrt(2)/sqrt(eig_num));          %����l1������С�����ع������ֵ

right = 0;
class_recT = zeros(40 * Test_num, 1);
for i = 1 : Test_num * 40
    x0 = eigenface' * eigenfaceT(:,i);                                     %���������ʼ��x0
    xp = l1qc_logbarrier(x0, eigenface, [], eigenfaceT(:, i), e, 1e-4);    %���l1��С������
    ry = zeros(40, 1);
    for j = 1 : 40                                                         %���������ع�
        deltaj = zeros(Train_num * 40, 1);
        deltaj((j - 1) * 8 + 1 : (j - 1) * 8 + 8) = xp((j - 1) * 8 +...
            1 : (j - 1) * 8 + 8);
        ry(j) = norm(eigenfaceT(:,i) - eigenface * deltaj)^2;
    end
    [minry index] = sort(ry);                                              %�ع������С������Ϊʶ����
    class_recT(i) = index(1);
    if class_recT(i) == class_T(i)
        right = right + 1;
    end        
end
display(right / (Test_num * 40));
rc = right / (Test_num * 40);



