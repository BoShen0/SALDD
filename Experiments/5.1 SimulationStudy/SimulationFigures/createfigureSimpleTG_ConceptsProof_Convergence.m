figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1,...
    'Position',[0.111964171465131 0.116911764705882 0.865642994241843 0.849264705882353]);
hold(axes1,'on');

% Create multiple lines using matrix input to plot
plot1 = plot(YMatrix1,'LineWidth',2,...
    'Parent',axes1);
set(plot1(1),'DisplayName',[char(949) '_{t}=0']);
set(plot1(2),'DisplayName',[char(949) '_{t}=0.2\cdot||\theta_{t}||'],'LineStyle','--');
set(plot1(3),'DisplayName',[char(949) '_{t}=0.4\cdot||\theta_{t}||'],'LineStyle','-.');
set(plot1(4),'DisplayName',[char(949) '_{t}=0.6\cdot||\theta_{t}||'],'LineStyle',':');
set(plot1(5),'DisplayName',[char(949) '_{t}=0.8\cdot||\theta_{t}||'],'LineStyle','-',...
    'MarkerIndices',1:20:500,'Marker','o','MarkerSize',3);

% Create ylabel
% ylabel('Average Loss','FontWeight','bold');
ylabel('# Selected Features','FontWeight','bold');

% Create xlabel
xlabel('# Instances','FontWeight','bold');

box(axes1,'on');
% Set the remaining axes properties
set(axes1,'FontSize',16,'FontWeight','bold');
% Create legend
legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.671678390861908 0.466030926911777 0.307421630464604 0.23991655623631],...
    'FontSize',16);

