// Script taken from GDMuse (also created by me): https://github.com/kiwijuice56/gd-muse/tree/master/godot-project/main/ui/data_panel/stream_panel/chart
using Godot;
using System;
using System.Collections.Generic;

[GlobalClass]
public partial class FastChart : PanelContainer {
	[Export]
	public double timeWindow = 8.0;
	[Export]
	public double delay = 0.45;
	[Export]
	public Color lineColor;
	[Export]
	public double padding = 0.2;
	[Export]
	public double lineWidth = 0.9;
	[Export]
	public long timestampThreshold = 20000;


	private List<double> stream;
	private List<long> timestamps;

	public override void _Ready() {
		Reset();
	}

	public override void _Process(double delta) {
		QueueRedraw();
	}

	public override void _Draw() {
		if (timestamps.Count == 0) {
			return;
		}

		double maxY = double.NegativeInfinity;
		double minY = double.PositiveInfinity;

		for (int i = 0; i < stream.Count; i++) {
			maxY = Mathf.Max(maxY, stream[i]);
			minY = Mathf.Min(minY, stream[i]);
		}

		if (Mathf.IsEqualApprox(maxY, minY)) {
			double fakePadding = Math.Max(0.1, maxY * 0.1);
			maxY += fakePadding;
			minY -= fakePadding;
		}

		// Modification here: timestamps in this program are in ms
		long minX = (long) (1000.0 * (Time.GetUnixTimeFromSystem() - timeWindow - delay));
		long maxX = (long) (1000.0 * (Time.GetUnixTimeFromSystem() - delay));

		for (int i = 1; i < stream.Count; i++) {
			if (timestamps[i - 1] < minX || timestamps[i - 1] > maxX) {
				continue;
			}
			Vector2 from = new Vector2(
				(float) Fit(timestamps[i - 1], minX, maxX, Size.X),
				(float) (Size.Y - Fit(stream[i - 1], minY, maxY, Size.Y))
			);
			from.Y = (float) (from.Y * (1.0 - padding) + Size.Y * padding / 2.0);

			Vector2 to = new Vector2(
				(float) (Fit(timestamps[i], minX, maxX, Size.X)),
				(float) (Size.Y - Fit(stream[i], minY, maxY, Size.Y))
			);
			to.Y = (float) (to.Y * (1.0 - padding) + Size.Y * padding / 2.0);
			to.X = Mathf.Min(Size.X, to.X);
			DrawLine(from, to, lineColor, (float) lineWidth, true);
		}

	}

	public double Fit(double v, double minV, double maxV, double scalar) {
		return (v - minV) / (maxV - minV) * scalar;
	}

	public void AddPoint(double value, long timestamp) {
		if (double.IsNaN(value) || double.IsInfinity(value)) {
			value = 0.0;
		}
		
		if (timestamps.Count == 0) {
			timestamps.Add(timestamp);
			stream.Add(value);
		}
		
		for (int i = timestamps.Count - 1; i >= 0; i--) {
			if (timestamps[i] < timestamp) {
				if (Mathf.Abs(timestamps[i] - timestamp) <= timestampThreshold) {
					return;
				}

				timestamps.Insert(i + 1, timestamp);
				stream.Insert(i + 1, value);
				break;
			}
		}

		while (timestamps[timestamps.Count - 1] - timestamps[0] > (timeWindow + delay) * 1000000) {
			stream.RemoveAt(0);
			timestamps.RemoveAt(0);
		}
	}
	
	public void Reset() {
		stream = new List<double>();
		timestamps = new List<long>();
	}
}
