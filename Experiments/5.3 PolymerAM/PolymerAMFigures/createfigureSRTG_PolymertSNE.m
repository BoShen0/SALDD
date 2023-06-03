% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1,...
    'Position',[0.0889315419065899 0.0863358259687288 0.872040946896993 0.870156356220259]);
hold(axes1,'on');

% Create plot
plot(Y(find(NewLabels == -2),1),Y(find(NewLabels == -2),2),'DisplayName','-2','Marker','o','MarkerSize',10,'LineWidth',3,'LineStyle','none',...
    'Color',[0.741176470588235 0.968627450980392 0.047058823529412]);

% Create plot
plot(Y(find(NewLabels == -1),1),Y(find(NewLabels == -1),2),'DisplayName','-1','Marker','o','MarkerSize',10,'LineWidth',3,'LineStyle','none',...
    'Color',[0.501960784313725 0.501960784313725 0.501960784313725]);

% Create plot
plot(Y(find(NewLabels == 1),1),Y(find(NewLabels == 1),2),'DisplayName','1','MarkerSize',22,'Marker','+','LineWidth',4,...
    'LineStyle','none',...
    'Color',[0 0 1]);

% Create plot
plot(Y(find(NewLabels == 2),1),Y(find(NewLabels == 2),2),'DisplayName','2','MarkerSize',22,'Marker','+','LineWidth',4,...
    'LineStyle','none',...
    'Color',[1 0 0]);

% Uncomment the following line to preserve the X-limits of the axes
% xlim(axes1,[-4.04281591231153 5.43291234273419]);
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'FontSize',16,'FontWeight','bold');
