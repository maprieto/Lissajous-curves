function hh = ezgrafica3(varargin)

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});

% Create plot 
cax = newplot(cax);
fig = ancestor(cax,'figure');

% % Check each input function or expression
% [x,x0,xargs] = ezfcnchk(args{1},0,'t');
% [y,y0,yargs] = ezfcnchk(args{2},0,'t');
% [z,z0,zargs] = ezfcnchk(args{3},0,'t');
x=args{1};
y=args{2};
z=args{3};

% allargs = union(xargs,union(yargs,zargs));
% numargs = length(allargs);
% if (ismember({''},allargs)), numargs = max(1, numargs-1); end
% if (numargs == 2)
%    error(id('ParameterizedSurface'),'To plot parametrized surfaces, use EZSURF')
% elseif (numargs > 2)
%    error(id('InvalidFunctions'),'Functions must take one argument.');
% end

Aflag = 0; % Animation option.

Npts = 1000; % originally 300

% Determine the domain in t:
switch nargs
   case 3
      T =  linspace(0,2*pi,Npts);
   case 4
      if isa(args{4},'double')   
         T = linspace(args{4}(1),args{4}(2),Npts);
      elseif isequal(args{4},'animate')
         Aflag = 1;
         T =  linspace(0,2*pi,Npts);
      else
         T =  linspace(0,2*pi,Npts);
      end
   case 5
      if isa(args{4},'double') && isequal(args{5},'animate') 
         Npts=1000*(args{4}(2)-args{4}(1))/(2*pi);
         T = linspace(args{4}(1),args{4}(2),Npts);
         Aflag = 1;
      elseif isequal(args{4},'animate') && isa(args{5},'double')
         Npts=1000*(args{5}(2)-args{5}(1))/(2*pi);
         T = linspace(args{5}(1),args{5}(2),Npts);
         Aflag = 1;
      else
         T = linspace(0,2*pi,Npts);
      end
end


% Evaluate each of (X,Y,Z)
%fx=str2func(['@(t) ',x]);
eval(['fx=@(t) ',vectorize(x),';']);
X = fx(T);
if numel(X) == 1
   X = X*ones(size(T));
end
%fy=str2func(['@(t) ',y]);
eval(['fy=@(t) ',vectorize(y),';']);
Y = fy(T);
if numel(Y) == 1
   Y = Y*ones(size(T));
end
%fz=str2func(['@(t) ',z]);
eval(['fz=@(t) ',vectorize(z),';']);
Z = fz(T);
if numel(Z) == 1
   Z = Z*ones(size(T));
end

% Option to Return a handle.
h = plot(X,Y,'parent',cax);

xlabel(cax,'x(t)'); ylabel(cax,'y(t)')
%title(cax,['x = ' texlabel(x0), ', y = ' texlabel(y0)]);
grid(cax,'on');

if Aflag
   hold(cax,'on');
   H = plot(X(1),Y(1),'r.','erasemode','xor','markersize',24,'parent',cax);

   dk = ceil(length(Y)/Npts);
   % run once with timing so that we see how fast this machine is
   tic
   set(H,'xdata',X(1),'ydata',Y(1));
   drawnow;
   tm = 0.00003/toc;
   for k = 2:dk:length(Y)
      set(H,'xdata',X(k),'ydata',Y(k));
      pause(tm);
      drawnow;
   end
   % Define the userdata for the callback.
   ud.x = X; ud.y = Y; ud.dk = dk; ud.h = H; ud.tm = tm; ud.cax = cax;
   set(fig,'userdata',ud);
end
end
 
