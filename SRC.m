function rc = SRC(m_img, n_img, V, class_V, Train_num, T, class_T, Test_num)
%V-----------------ѵ�����ݼ���[m*n, Train_num*15]
%m_img-------------V��ͼ���ά��
%n_img-------------V��������
%r-----------------V����
%Train_num---------ѵ��������
%maxiter-----------����������
%T-----------------�������ݼ���[m*n, Test_num*15]
%Test_num----------ѵ��������

B = [V eye(m_img * n_img)];                                                %�������
B = normc(B);                                                              %��һ��ģ
T = normc(T);
e0 = zeros(m_img * n_img, 1);                                              %��Ⱦʸ����ʼ��
e = 0.0005 * sqrt(m_img * n_img) * sqrt(1 +...
    2 * sqrt(2)/sqrt(m_img * n_img));

right = 0;
class_recT = zeros(40 * Test_num, 1);
for i = 1 : Test_num * 40
    x0 = B(:, 1 : Train_num * 40)' * T(:,i);                               %���������ʼ��x0
    x0 = [x0; e0];
    xp = l1qc_logbarrier(x0, B, [], T(:, i), e, 1e-4);                     %���l1��С������
    yr = T(:,i) - xp(Train_num * 40 + 1 : end);
    ry = zeros(40, 1);
    for j = 1 : 40                                                         %���������ع�
        deltaj = zeros(Train_num * 40, 1);
        deltaj((j - 1) * 8 + 1 : (j - 1) * 8 + 8) = xp((j - 1) * 8 +...
            1 : (j - 1) * 8 + 8);
        ry(j) = norm(yr - B(:, 1 : Train_num * 40) * deltaj)^2;
    end
    [minry index] = sort(ry);                                              %�ع������С������Ϊʶ����
    class_recT(i) = index(1);
    if class_recT(i) == class_T(i)
        right = right + 1;
    end        
end
display(right / (Test_num * 40));
rc = right / (Test_num * 40);
