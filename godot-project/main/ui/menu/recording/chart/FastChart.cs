// Script taken from GDMuse (also created by me): https://github.com/kiwijuice56/gd-muse/blob/master/godot-project/main/ui/recording_data_panel/stream_panel/chart/FastChart.cs
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
	public Color peakColor;
	[Export]
	public double padding = 0.2;
	[Export]
	public int peakLength = 4;
	[Export]
	public double lineWidth = 0.9;
	[Export]
	public double peakRadius = 3.5;
	[Export]
	public bool live;

	private List<double> stream;
	private List<long> timestamps;
	private List<int> peakIndices;

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
		
		if (!live) {
			minX = Int64.MaxValue;
			maxX = Int64.MinValue;
			for (int i = 0; i < timestamps.Count; i++) {
				maxX = Math.Max(maxX, timestamps[i]);
				minX = Math.Min(minX, timestamps[i]);
			}
		}

		List<Vector2> points = new List<Vector2>();
		List<Vector2> circles = new List<Vector2>();
		int peakCounter = 0;
		for (int i = 1; i < stream.Count; i++) {
			if ((i != stream.Count - 1 && timestamps[i + 1] < minX) || timestamps[i] > maxX) {
				continue;
			}
			Vector2 from = new Vector2(
				(float) Fit(timestamps[i - 1], minX, maxX, Size.X),
				(float) (Size.Y - Fit(stream[i - 1], minY, maxY, Size.Y))
			);
			
			from.Y = (float) (from.Y * (1.0 - padding) + Size.Y * padding / 2.0);
			points.Add(new Vector2(from.X, from.Y));
			
			if (peakCounter < peakIndices.Count && (peakIndices[peakCounter] - i) <= peakLength) {
				circles.Add(new Vector2(from.X, from.Y));
				if (i == peakIndices[peakCounter]) {
					peakCounter += 1;
				}
			}
		}
		
		if (points.Count > 2) {
			DrawPolyline(points.ToArray(), lineColor, (float) lineWidth);
		}
		
		for (int i = 0; i < circles.Count; i++) {
			DrawCircle(circles[i], (float) peakRadius, peakColor);
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
		peakIndices = new List<int>();
	}
	
	// Pass in the stream as integers, just for ease since internally PPG values are ints
	public void Initialize(int[] newStream, long[] newTimestamps) {
		stream = new List<double>(newStream.Length);
		for (int i = 0; i < newStream.Length; i++) {
			stream.Add((double) newStream[i]);
		}
		timestamps = new List<long>(newTimestamps.Length);
		for (int i = 0; i < newTimestamps.Length; i++) {
			timestamps.Add(newTimestamps[i]);
		}
		peakIndices = new List<int>();
	}
	
	public void InitializeDebug(double[] newStream, long[] newTimestamps, int[] newPeakIndices) {
		stream = new List<double>(newStream.Length);
		for (int i = 0; i < newStream.Length; i++) {
			stream.Add(newStream[i]);
		}
		timestamps = new List<long>(newTimestamps.Length);
		for (int i = 0; i < newTimestamps.Length; i++) {
			timestamps.Add(newTimestamps[i]);
		}
		peakIndices = new List<int>(newPeakIndices.Length);
		for (int i = 0; i < newPeakIndices.Length; i++) {
			peakIndices.Add(newPeakIndices[i]);
		}
	}
}
