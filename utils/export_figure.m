function export_figure(f, out_file, size_cm, varargin)
%EXPORT_FIGURE Resize figure f to size_cm = [width height] (cm) and save it
%   as a vector PDF. Extra arguments are passed to exportgraphics.

    set(f, 'Units', 'centimeters', 'Position', [2, 2, size_cm]);
    exportgraphics(f, out_file, 'ContentType', 'vector', varargin{:});
    fprintf('Saved %s\n', out_file);
end
